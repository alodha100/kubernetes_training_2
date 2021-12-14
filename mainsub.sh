#Function for SUB Routine - VM PREP 

function sshhost()
{
cat <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
}

#function yumrepo()
# {
#ssh droot@$PIP  "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
#ssh droot@$PIP  "sudo yum makecache"
##ssh droot@$PIP  "sudo yum install docker-ce -y"
#ssh droot@$PIP  "sudo systemctl start docker"
#ssh droot@$PIP  "sudo systemctl enable docker"
# }

function pubip()
{
#Get IP address of vm001
PIP=$(az vm show -d -g vm001_rg -n vm001 --query "publicIps" -o tsv)
}

function open_ssh()
{

 NSGNAME=$(az network nsg list -o tsv  | grep mc_aks | awk '{print $6}')
 AKSRGNAME=$(az network nsg list -o tsv  | grep mc_aks | awk '{print $9}')

}

function open_pub()
{
# this is Dangerous, but for Training, NO PROBLEM , let them hack, there is nothing inside 
az network nsg rule create -g vm001_rg --nsg-name vm001-nsg -n open_public --priority 777 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 1111-2049  --access Allow \
    --protocol Tcp --description "Open NFS Port" > /dev/null 
}

function open_aks_ssh()
{
open_ssh 
az network nsg rule create -g $AKSRGNAME --nsg-name $NSGNAME -n open_ssh --priority 772 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 22  --access Allow \
    --protocol Tcp --description "Open SSH Port" > /dev/null 

az network nsg rule create -g $AKSRGNAME --nsg-name $NSGNAME -n open_nfs --priority 773 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 2049  --access Allow \
    --protocol Tcp --description "Open NFS Port" > /dev/null 

}

function aks_subnet()
{

RG=$(az network vnet list -o tsv | grep MC  | awk '{print $15}') 
VNET=$(az network vnet list -o tsv | grep MC  |  awk '{print $13}')
SUBNET=$(az network vnet subnet list --vnet-name $VNET --resource-group $RG  -o tsv  | awk '{print $1}') 

}

function config_vm001()
{
#Configure vm001 with yum, disable Firewall , enable docker/nfs and run docker/nfs
#Show user the PUBLIC IP address to connect 
#Print How to connect from WINDOZE system using PUTTY

#Open AKS SSH port
open_aks_ssh

#Disable strict host check
sshhost > $HOME/.ssh/config

#Plumb Public IP
pubip

#call yumrepo function to install and settle Docker
#yumrepo &> /dev/null

#Enable root key based access 
#ssh -i $HOME/.ssh/id_rsa  droot@$PIP  "sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin without-password/g'  /etc/ssh/sshd_config"
#ssh -i $HOME/.ssh/id_rsa  droot@$PIP  "sudo touch /etc/cloud/cloud-init.disabled"
#ssh -i $HOME/.ssh/id_rsa  droot@$PIP  "sudo reboot"

#Wait for reboot to complete
#sleep 120 

#RePlumb IP after reboot
#pubip

#Call aks_subnet
aks_subnet

#prep shellcode for injection
cat <<AA > ak.sh
#!/bin/bash

# This script should be executed on Linux Ubuntu Virtual Machine

EXPORT_DIRECTORY=/export/data
DATA_DIRECTORY=/data
AKS_SUBNET=$SUBNET

echo "Updating packages"
apt-get -y update

echo "Installing NFS kernel server"

apt-get -y install nfs-kernel-server

echo "Making data directory \${DATA_DIRECTORY}"
mkdir -p \${DATA_DIRECTORY}

echo "Making new directory to be exported and linked to data directory: \${EXPORT_DIRECTORY}"
mkdir -p \${EXPORT_DIRECTORY}

echo "Mount binding ${DATA_DIRECTORY} to \${EXPORT_DIRECTORY}"
mount --bind \${DATA_DIRECTORY} \${EXPORT_DIRECTORY}

echo "Giving 777 permissions to \${EXPORT_DIRECTORY} directory"
chmod 777 \${EXPORT_DIRECTORY}

parentdir="\$(dirname "\$EXPORT_DIRECTORY")"
echo "Giving 777 permissions to parent: \${parentdir} directory"
chmod 777 \$parentdir

echo "Appending bound directories into fstab"
echo "\${DATA_DIRECTORY}    \${EXPORT_DIRECTORY}   none    bind  0  0" >> /etc/fstab

echo "Appending localhost and Kubernetes subnet address \${AKS_SUBNET} to exports configuration file"
echo "/export        \${AKS_SUBNET}(rw,async,insecure,fsid=0,crossmnt,no_subtree_check,no_root_squash)" >> /etc/exports
echo "/export        localhost(rw,async,insecure,fsid=0,crossmnt,no_subtree_check,no_root_squash)" >> /etc/exports

nohup service nfs-kernel-server restart

AA

#Inject ShellCode and run
scp -i $HOME/.ssh/id_rsa  ak.sh  droot@$PIP:/home/droot/  
ssh -i $HOME/.ssh/id_rsa  droot@$PIP  "sudo chmod +x ak.sh" 
ssh -i $HOME/.ssh/id_rsa  droot@$PIP  "sudo ./ak.sh" 


#call openpub to allow incoming net traffic
open_pub

#Display INFO for Student
#echo 
echo -e "vm001 fully deployed..."
#echo 
#echo -e "\e[93mDownload this file ($HOME/.ssh/id_rsa) to your WinDOZE computer and refer to \e[92mhttps://www.puttygen.com/convert-pem-to-ppk \e[93mto convert and use putty to connect to $PIP"
#echo 
#echo -e "\e[93mPublic IP address for your vm001 is $PIP"
#echo 
#echo -e "\e[93mFrom Azure Cloud Shell, you can execute  ( ssh -i \$HOME/.ssh/id_rsa root@$PIP )"
#echo -e "\e[93mEnjoy...- Steven.Com.My"
#echo -e "\033[0m"
}