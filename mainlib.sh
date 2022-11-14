# Functions 
function my_usage()
{
  echo 
  echo -e "\e[31mError  : No Arg or Invalid Arg Passed.. Try again\e[0m"
  echo -e "\e[42mUsage  : $0 vm001|k8s|cloud|aks\e[0m"
  echo -e "\e[42mExample: $0 vm001\e[0m"
  echo 
}

function addssh()
{
 if [ -f $HOME/.ssh/id_rsa.pub ]
 then 
 SSHPUB=$(cat $HOME/.ssh/id_rsa.pub)
 else 
 ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''  &>  /dev/null
 SSHPUB=$(cat $HOME/.ssh/id_rsa.pub)
 fi
}

function  runtest()
{
az group list | grep ${VMNAME}_rg &> /dev/null
RET=$?
}

function rerun()
{
 echo -e "\e[31mNo RERUN allowed, [ \e[93m$VMNAME \e[0m\e[31m] resources already been defined...\e[0m"
 exit 22
}

function subid()
{
SUBID=$(az account list | grep id | awk '{print $2}'  | sed 's/"//g' | sed 's/,//g')
#virtualNetworkId="/subscriptions/${SUBID}/resourceGroups/k8s_rg/providers/Microsoft.Network/virtualNetworks/ks8_rg-vnet"
#networkSecurityGroupId="/subscriptions/${SUBID}/resourceGroups/k8s_rg/providers/Microsoft.Network/networkSecurityGroups/vm002-nsg"
}

function aksvnet () 
{

AKSVNET=$(az network vnet list -o tsv | grep MC  | awk '{print $10}') 

}


function deploy_vm001()
{
 aksvnet
 echo "Deploying Node (vm001)....standby"
 #echo $AKSVNET
 if [ ! -z $AKSVNET ]
 then
 az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_template.json -p ./${VMNAME}/${VMNAME}_parameters.json   -p  adminPublicKey="$SSHPUB"  -p virtualNetworkId="$AKSVNET" > /dev/null 
 sleep 20
 echo "Deployment of vm001...PASS"
 else 
 echo "Aks VNET not found... vm001 deployment....FAIL"
 exit 33
 fi 

}

function deploy_k8s()
{
#k8s vnet deploy
echo "Deploying vnet for k8s....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_vnet_template.json -p ./${VMNAME}/${VMNAME}_vnet_parameters.json > /dev/null 
sleep 10
echo "Deployment of vnet for k8s...PASS"

#k8s Master VM deploy
echo "Deploying Master Node (vm002)....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_master_template.json -p ./${VMNAME}/${VMNAME}_master_parameters.json   -p  adminPublicKey="$SSHPUB" -p virtualNetworkId="$virtualNetworkId"> /dev/null
echo "Deployment of vm002 for k8s...PASS"

#k8s Node1 Deploy
echo "Deploying Worker Node1 (vm003)....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_node1_template.json -p ./${VMNAME}/${VMNAME}_node1_parameters.json   -p  adminPublicKey="$SSHPUB" -p virtualNetworkId="$virtualNetworkId"  -p networkSecurityGroupId="$networkSecurityGroupId" > /dev/null  
echo "Deployment of vm003 for k8s...PASS"

#k8s Node2 Deploy
echo "Deploying Worker Node2 (vm004)....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_node2_template.json -p ./${VMNAME}/${VMNAME}_node2_parameters.json   -p  adminPublicKey="$SSHPUB"  -p virtualNetworkId="$virtualNetworkId" -p networkSecurityGroupId="$networkSecurityGroupId" > /dev/null  
echo "Deployment of vm004 for k8s...PASS"

}


function deploy_aks()
{

echo "Deploying Azure Kubernetes Services....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_template.json -p ./${VMNAME}/${VMNAME}_parameters.json  > /dev/null
echo "Deployment of Azure Kubernetes Service ....PASS"
echo 
echo "Standby for Vital INFO...."
DNS=$(az aks show --resource-group aks_rg --name aks_lab --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table | grep \\. ) 
sleep 5 
SUBID=$(az account list | grep id | awk '{print $2}'  | sed 's/"//g' | sed 's/,//g')

echo "Azure Sub ID: $SUBID"
echo "AKS Cluster Name: aks_lab"
echo "AKS Resource Group Name: aks_rg"
echo "AKS DNS for ingress: $DNS"
echo "Please keep this info for future reference"

}

function info_aks()
{
DNS=$(az aks show --resource-group aks_rg --name aks_lab --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table | grep \\. ) 
SUBID=$(az account list | grep id | awk '{print $2}'  | sed 's/"//g' | sed 's/,//g')
cat <<EOF
Azure Sub ID: $SUBID
AKS Cluster Name: aks_lab
AKS Resource Group Name: aks_rg
AKS DNS for ingress: $DNS
Please keep this info for future reference
EOF

}



function deploy_aci()
{
RAND=$(openssl rand -hex 3)
echo "Deploying Azure Container Instances....standby"
az deployment group create -g ${VMNAME}_rg -f ./${VMNAME}/${VMNAME}_aci_template.json -p ./${VMNAME}/${VMNAME}_aci_parameters.json -p dnsNameLabel="mynginx$RAND" > /dev/null
echo "Deployment of Azure Container Instances ....PASS"
echo
ACI=$(az container list  | grep fqdn  | awk '{print $2}'  | sed 's/"//g' | sed 's/,//g')
echo -e "your FQDN for deployed Azure Container Instance is:  http://$ACI"
echo -e "User your browser to navigate there and see your ACI Instance in Action"
}

function  createrg_vm001()
{
  runtest 
  if [ $RET -eq 0 ]
   then 
   rerun
   else 
   echo "Creating Resources.... standby..."
   az group create -l $LOC -n ${VMNAME}_rg > /dev/null 
   deploy_vm001 
   fi 
}

function createrg_k8s()
{
    runtest
    if [ $RET -eq 0 ]
    then
    rerun
    else
    echo "Creating k8s Master Node and 2 worker Node"
    echo "Creating Resources.... standby..."
    az group create -l $LOC -n ${VMNAME}_rg > /dev/null 
    deploy_k8s
    fi
}

function createrg_cloud()
{
    runtest 
    if [ $RET -eq 0 ]
    then 
    rerun
    else 
    echo "Creating Resources.... standby..."
    az group create -l $LOC -n ${VMNAME}_rg > /dev/null 
    deploy_aci 
    fi 
}

function createrg_cloud_aks()
{
    runtest 
    if [ $RET -eq 0 ]
    then 
    rerun
    else 
    echo "Creating Resources.... standby..."
    az group create -l $LOC -n ${VMNAME}_rg > /dev/null 
    deploy_aks
    fi 
}

function reinit()
{
  if [ -f tmpdata ]
   then 
    rm -rf tmpdata 
  fi 
  touch tmpdata
  for i in vm001_rg k8s_rg cloud_rg aks_rg
  do 
   az group list | grep $i &> /dev/null
   if  [ $? -eq 0  ]
    then 
    echo "${i}" >> tmpdata
  fi 
  done
  echo "Quit" >> tmpdata 
  
  PS3="[ WARNING - this is irreversible ] Select Resource to Delete: "
  select opt in $(cat tmpdata)
   do
    case $opt in 
    'vm001_rg')   az group delete -n vm001_rg 
                  break  ;;
    'k8s_rg'  )   az group delete -n k8s_rg
                  break ;;
    'cloud_rg')   az group delete -n cloud_rg 
                  break ;;
    'aks_rg'  )   az group delete -n aks_rg 
                  break ;; 
    'Quit'    )   echo "Exit" && break ;;
    esac
  done 
}

function locset()
{
az account list-locations --query '[?metadata.physicalLocation!='null'].{Loc:name, AL:metadata.physicalLocation, R:regionalDisplayName }' -o json > locdata
cat locdata  | jq -c '.[] ' | sed 's/[}{]//g' | sed 's/\"//g'  | awk -F, '{print $1,$3,$2}' | sed 's/AL://g' | sed 's/R://g' > ddata
readarray -t IN < ddata

PS3="Select your nearest Location to Deploy:  "

  select answer in "${IN[@]}"; do
  for item in "${IN[@]}"; do
    if [[ $item == $answer ]]; then
      break 2
    fi
  done
done
grep "$answer"  ddata | awk -F: '{print $2}' > $HOME/.loc
LOC=$(cat $HOME/.loc)
rm -rf locdata ddata
clear
}

function setloc()
{
if [ -s $HOME/.loc ]
 then
 LOC=$(cat $HOME/.loc)
 #echo "Seems the location already set to $LOC"
 #echo -e "Are we Okay with this?[ ]\b\b\c"
 #read ASTA
 #  if [ $ASTA == 'n' ]
 #  then 
 #  locset
 #  fi 
fi 
}

function non()
{

echo "Invalid option"
echo "This training is for aks, please rerun with aks option"

}