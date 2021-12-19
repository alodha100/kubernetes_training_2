#  Lab02-Extra - Pods Security Policy
# Step 1 
Enable pod security policy in AKS 
- requirement for running in your own system: 
    * az cli version 2.0.61 or later 
    * run "az --version" to verify you have az cli version 2.0.61
    * if you don't have, visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

- If the above requirements cannot be met, then use Azure Cloud Shell where your AKS is installed.

```sh
az extension add --name aks-preview

az extension update --name aks-preview

az feature register --name PodSecurityPolicyPreview --namespace Microsoft.ContainerService

az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSecurityPolicyPreview')].{Name:name,State:properties.state}"

**Please wait until status shows registered!! ( it will take several Minutes )
**Run a simple infinite loop with the previous command to view the status

az provider register --namespace Microsoft.ContainerService

az aks update --resource-group aks_rg --name aks_lab --enable-pod-security-policy

kubectl get psp | sed '1p;/privileged/!d'
```

# Step 2 
Create a test user in an AKS cluster
- by default AKS uses AAD integration for credentials , otherwise the default kubernetes context falls under admin role.
- The admin user bypasses the enforcement of pod security policies.
- Since AAD is not in our topic, we will create a simulated non-admin user to test pod SecurityContext. ( using serviceaccount )

```sh
kubectl create namespace psp-aks

kubectl create serviceaccount --namespace psp-aks nonadmin-user

kubectl create rolebinding --namespace psp-aks psp-aks-editor  --clusterrole=edit --serviceaccount=psp-aks:nonadmin-user

kubectl get rolebindings.rbac.authorization.k8s.io -n psp-aks

alias kubectl-admin='kubectl --namespace psp-aks'

alias kubectl-nonadminuser='kubectl --as=system:serviceaccount:psp-aks:nonadmin-user --namespace psp-aks'
```

# Step 3 
Test the creation of a privileged pod

```sh
cat nginx-privileged.yaml

kubectl-nonadminuser apply -f nginx-privileged.yaml

**expected to fail 
**the pod specification requested privileged escalation
**This request is denied by the default privilege pod security policy, so the pod fails to be scheduled
```

# Step 4 
Test creation of an unprivileged pod

```sh
cat nginx-unprivileged.yaml

kubectl-nonadminuser apply -f nginx-unprivileged.yaml

**expected to fail 
**the container image automatically tried to use root to bind NGINX to port 80.
**This request was denied by the default privilege pod security policy, so the pod fails to start
```

# Step 5
Test creation of a pod with a specific user context

```sh

cat nginx-unprivileged-nonroot.yaml

kubectl-nonadminuser apply -f nginx-unprivileged-nonroot.yaml

**expected to fail 
**the container image automatically tried to use userid 2000 to bind NGINX to port 80.
**This request was denied by the default privilege pod security policy, so the pod fails to start
```

# Step 6
Create a custom pod security policy

```sh

cat psp-deny-privileged.yaml

kubectl apply -f psp-deny-privileged.yaml

kubectl get psp | sed '1p;/privileged/!d'
```

# Step 7
Allow user account (service Account) to use the custom pod security policy

```sh

kubectl apply -f psp-deny-privileged-clusterrole.yaml

kubectl apply -f psp-deny-privileged-clusterrolebinding.yaml

kubectl get clusterrolebindings.rbac.authorization.k8s.io  | grep psp
```


# Step 8
Test the creation of an unprivileged pod again

```sh
kubectl-nonadminuser apply -f nginx-unprivileged.yaml

kubectl-nonadminuser get pods

kubectl-nonadminuser delete -f nginx-unprivileged.yaml
```

# Step 9
Test the creation of an privileged pod 

```sh
kubectl-nonadminuser apply -f nginx-privileged.yaml

**expected to fail 
**Policy do not allow privileged pod.
```

# Step 10 
Test the creation of an unprivileged  non root pod 

```sh 
kubectl-nonadminuser apply -f nginx-unprivileged-nonroot.yaml

kubectl-nonadminuser get pods

kubectl logs nginx-unprivileged-nonroot  -n psp-aks
```

# Step 11 
Edit the nginx-unprivileged-nonroot.yaml and set the runAsUser as 0 

```sh 
kubectl-nonadminuser delete -f nginx-unprivileged-nonroot.yaml

vim nginx-unprivileged-nonroot.yaml
**Change runAsUser to 0 

kubectl-nonadminuser apply -f nginx-unprivileged-nonroot.yaml

kubectl-nonadminuser get pods
```

# Step 12 
Clean Up
```sh
az aks update --resource-group aks_rg --name aks_lab --disable-pod-security-policy

kubectl delete -f psp-deny-privileged-clusterrolebinding.yaml

kubectl delete -f psp-deny-privileged-clusterrole.yaml

kubectl delete -f psp-deny-privileged.yaml

kubectl delete namespace psp-aks
```


### END