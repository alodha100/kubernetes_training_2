#Function for SUB Routine 2 - VM PREP

#Disable strict host check function
function sshhost2()
{
cat <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
}

##SHELL CODE to inject into vm00[2-4]
function mainprog2()
{
cat <<EOF
#!/bin/bash 

 setenforce 0
 sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g'  /etc/sysconfig/selinux
 systemctl disable firewalld && systemctl stop firewalld

cat <<EO > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EO

yum install -y docker kubelet kubeadm kubectl kubernetes-cni git
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

sysctl -w net.bridge.bridge-nf-call-iptables=1
echo "net.bridge.bridge-nf-call-iptables=1" > /etc/sysctl.d/k8s.conf

swapoff -a 
touch /etc/cloud/cloud-init.disabled

cat <<EF > /home/droot/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EF

cat <<EFA > /root/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EFA

sed -i 's/^#PermitRootLogin yes/PermitRootLogin without-password/g'  /etc/ssh/sshd_config 
cat /home/droot/.ssh/authorized_keys  > /root/.ssh/authorized_keys

cp /home/droot/p.key  /root/p.key
echo "alias ssh='ssh -i /root/p.key'"  >> /root/.bashrc

echo "$PIP2A  master.example.local"  >> /etc/hosts 
echo "$PIP3  node1.example.local"  >> /etc/hosts
echo "$PIP4  node2.example.local"  >> /etc/hosts

EOF
}

function pubip2()
{
#Get IP address of vm002
PIP2=$(az vm show -d -g k8s_rg -n vm002 --query "publicIps" -o tsv)
PIP2A=$(az vm show -d -g k8s_rg -n vm002 --query "privateIps" -o tsv)
PIP3=$(az vm show -d -g k8s_rg -n vm003 --query "privateIps" -o tsv)
PIP4=$(az vm show -d -g k8s_rg -n vm004 --query "privateIps" -o tsv)
}

function open_pub2()
{
# this is Dangerous, but for Training, NO PROBLEM , let them hack, there is nothing inside 
az network nsg rule create -g k8s_rg --nsg-name vm002-nsg -n openpublic --priority 707 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 1-65535  --access Allow \
    --protocol Tcp --description "Open all PORT for Kubernetes Container Testing" > /dev/null 
}

function config_k8s()
{
#Configure vm002 with yum, disable Firewall , enable docker/kubernetes and run docker
#Show user the PUBLIC IP address to connect 
#Print How to connect from WINDOZE system using PUTTY

#Disable strict host check
sshhost2 > $HOME/.ssh/config

#Plumb Public/Private IP
pubip2

#Generate ShellCode to inject 
mainprog2 > ku.sh 

#inject shellcode and private key to master node ( vm002) 
scp -i $HOME/.ssh/id_rsa  ku.sh droot@$PIP2:/home/droot/ku.sh 
scp -i $HOME/.ssh/id_rsa  $HOME/.ssh/id_rsa  droot@$PIP2:/home/droot/p.key

# config vm002 aka master
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "sudo chmod +x ku.sh"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "sudo ./ku.sh"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "sudo hostnamectl --static set-hostname master.example.local"

# config vm003 aka node1 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "scp -i p.key ku.sh droot@$PIP3:/home/droot/ku.sh"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP3 'sudo chmod +x ku.sh'" 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP3 'sudo ./ku.sh'" 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP3 'sudo hostnamectl --static set-hostname node1.example.local'" 

# config vm004 aka node2
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "scp -i p.key ku.sh droot@$PIP4:/home/droot/ku.sh"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP4 'sudo chmod +x ku.sh'" 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP4 'sudo ./ku.sh'" 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP4 'sudo hostnamectl --static set-hostname node2.example.local'" 

#reboot seq 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP4 'sudo reboot'"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "ssh -i p.key droot@$PIP3 'sudo reboot'"
ssh -i $HOME/.ssh/id_rsa  droot@$PIP2  "sudo reboot"

#wait for reboot to complete
sleep 71

#call openpub to allow incoming net traffic
open_pub2

#Print END message 
echo 
echo -e "\e[93mvm002,vm003,vm004 fully deployed...you may use the same private key from Lesson Docker to connect to master node ip $PIP2"
echo 
echo -e "\e[93mPublic IP address for your vm002 is $PIP2"
echo 
echo -e "\e[93mFrom Azure Cloud Shell, you can execute  [ ssh -i \$HOME/.ssh/id_rsa root@$PIP2 ]"
echo
echo -e "\e[93m                      /---> node1.example.local"
echo -e "\e[93mmaster.example.local-|"
echo -e "\e[93m                      \---> node2.example.local"
echo 
echo -e "\e[93mEnjoy...- Steven.Com.MY"
echo -e "\033[0m"
}