#  Explore Kubernetes Cluster 


Explore and Verify Kubernetes ( AKS )
# Step 1 

Access Azure Cloud Shell and Connect to AKS

- Initiate Azure Cloud Shell ( you may be asked to create storage account when you run Azure Cloud Shell for First time, accept the default)

- Select Bash if prompted 

- Run the following command on Azure Cloud Shell

```sh
User@Azure#> az account set --subscription $(az account list | grep id | awk '{print $2}'  | sed 's/"//g' | sed 's/,//g')

User@Azure#> az aks get-credentials --resource-group aks_rg --name aks_lab

User@Azure#> cat .kube/config 

User@Azure#> kubectl get nodes 

User@Azure#> kubectl get nodes -o wide

User@Azure#> kubectl describe node <node_name>

```

# Step 2 

Open a SSH connection to worker node
 - replace node_name with your first worker node name 
```sh
User@Azure#> kubectl get nodes 

User@Azure#> kubectl debug node/<node_name> -it --image=mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11

root@aks-agentpool-25073747-0:/# chroot /host

# crictl ps

# crictl images ls 

# systemctl status kubelet

# systemctl status containerd

# crictl ps | grep kube-proxy

# cat /etc/*rel*

# uname -a

# lscpu 

# free -h 

# exit

root@aks-agentpool-25073747-0:/# exit

User@Azure#> kubectl get pods --field-selector status.phase!=Running 
NAME                                           READY   STATUS      RESTARTS   AGE
node-debugger-XXX                              0/1     Completed   0          13m

User@Azure#> kubectl  delete pod node-debugger-XXX

```

# Step 3 

Explore all running Containers/Pods and Configurations
```sh

User@Azure#>  kubectl get ns 

User@Azure#>  kubectl get po -n kube-system

User@Azure#>  kubectl get service 

User@Azure#>  kubectl get deployments

User@Azure#>  kubectl get daemonsets

User@Azure#>  kubectl get replicasets 

User@Azure#>  kubectl get statefulsets 

User@Azure#>  kubectl get configmap 

User@Azure#>  kubectl get secret 

User@Azure#>  kubectl get storageclass 

User@Azure#>  kubectl get pv

User@Azure#>  kubectl get pvc

User@Azure#>  kubectl get cronjobs

User@Azure#>  kubectl get jobs

User@Azure#>  kubectl get endpoints

```

# Step 4 

Deploy Simple App to Kubernetes
```sh
User@Azure#>  kubectl get deployments

User@Azure#>  kubectl get service 

User@Azure#>  kubectl apply -f voteapp.yaml 

User@Azure#>  kubectl get service voteapp-frontend
** Browse to the external IP address to verify app is running

```

# Step 5

Remove previously deployed App and verify there is no Service, Pod and Deployment defined 
```sh 

User@Azure#>  kubectl delete -f voteapp.yaml 

User@Azure#>  kubectl get deployments

User@Azure#>  kubectl get svc

User@Azure#>  kubectl get po

```

#### END