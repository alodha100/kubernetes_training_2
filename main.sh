#!/bin/bash
#main.sh Script to create resources and Build VM in Azure
#Using Local SYS via git clone
#Function LIB
source  ./mainlib.sh
source  ./mainsub.sh
source  ./mainsub2.sh

# Variables
VMNAME=$1

echo eastasia > $HOME/.loc

#Overwrite location because southeastasia(singapore have no more resources)
LOC=eastasia

##main program
if [ $# -ne 1 ]
  then 
  my_usage #This will print USAGE
  exit
  else
  setloc #This will set RG Location 
  addssh #This will create local Private/Public Key for VM
  subid  #This will catch your Azure Subscription ID
  case ${VMNAME} in
  'vm001') createrg_vm001 && config_vm001 ;;
  'k8s'  ) non ;;#createrg_k8s  && config_k8s ;;
  'cloud') non ;;#createrg_cloud ;;
  'aks'  ) createrg_cloud_aks && info_aks > $HOME/aks_info.txt ;;
  'init' ) reinit   ;;
  'info' ) info_aks ;;
        *) my_usage ;;
  esac
fi