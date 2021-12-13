#!/bin/bash 

#Mod Setup NFS server on MasterNode 

rm -rf /nfsdata 


if [ ! -d /nfsdata ] 
then 
mkdir -p /nfsdata/{dat1,dat2,dat3}
chmod -R 777 /nfsdata
fi 


 yum install nfs-utils -y &> /dev/null 
 ssh -i $HOME/p.key node1.example.local "yum install nfs-utils -y &> /dev/null"
 ssh -i $HOME/p.key node2.example.local "yum install nfs-utils -y &> /dev/null"

 if [ -f /etc/exports ]
 then 
  rm -rf /etc/exports 
 fi 

 echo "/nfsdata/dat1 *(rw,sync,no_root_squash)"  > /etc/exports
 echo "/nfsdata/dat2 *(rw,sync,no_root_squash)"  >> /etc/exports
 echo "/nfsdata/dat3 *(rw,sync,no_root_squash)"  >> /etc/exports

systemctl start nfs-server rpcbind &> /dev/null 
systemctl enable nfs-server rpcbind &> /dev/null 

exportfs -r