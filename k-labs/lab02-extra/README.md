#  Lab02-Extra - Pods SecurityContext

# Step 1 
Enable pod security policy in AKS 
- requirement: 
    * az cli version 2.0.61 or later 
    * run az --version to verify you have az cli version 2.0.61
    * if you don't have, visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

- The following should be run in Azure Cloud Shell where your AKS is installed 

```sh
az extension add --name aks-preview

az extension update --name aks-preview

az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService

az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSecurityPolicyPreview')].{Name:name,State:properties.state}"

**Please wait until status shows registered!! 
**Run a simple infinite loop with the previous command to view the status

az provider register --namespace Microsoft.ContainerService

az aks update --resource-group aks_rg --name aks_lab --enable-pod-security-policy

kubectl get psp | grep privileged

```

# Step 2 
Create a test user in an AKS cluster
- by default AKS uses AAD integration for credentials , otherwise the default kubernetes context falls under admin role.
- The admin user bypasses the enforcement of pod security policies.
- Since AAD is not in our topic, we will create a simulated non-admin user to test pod SecurityContext. ( using serviceaccount )

```sh
kubectl create namespace psp-aks

kubectl create serviceaccount --namespace psp-aks nonadmin-user


```

# Step 3 
Create and Verify Multi Container Pod ( sidecar container )

```sh

```

# Step 4 
Inter-Pod Networking  

```sh



```

# Step 5
Create multi label for Pod/Deployment and Filter using Label

```sh


```

# Step 6
Labels can be attached to any Kubernetes object, including nodes

```sh


```

# Step 7
Create namespace to split pods to specific namespace 

```sh


```


# Step 8
Deploy pods on different namespaces

```sh


```

# Step 9
Delete/Remove pods

```sh


```

# Step 10 
Remove node label 

```sh 


```

END