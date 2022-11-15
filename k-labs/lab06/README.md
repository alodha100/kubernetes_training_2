# Lab06A
# Step 
Exposing metadata to pods 

```sh
cat downward-non-api.yaml
kubectl create -f downward-non-api.yaml

kubectl exec downward-no-api-env -- env | grep POD
kubectl exec -it downward-no-api-env -- sh
# env
# env | grep POD
# echo $NODE_NAME
# exit

cat downward-api-env.yaml
kubectl create -f downward-api-env.yaml

kubectl exec downward -- env | grep POD
kubectl exec -it downward -- sh
# env
# env | grep POD
# echo $NODE_NAME
# exit
```

# Lab06B
# Step 
Exposing metadata to pods using downwardAPI

```sh
kubectl delete -f downward-non-api.yaml
kubectl delete -f downward-api-env.yaml

kubectl create -f downward-api-volume.yaml

kubectl exec downward -- cat /etc/downward/labels
kubectl exec downward -- cat /etc/downward/annotations
kubectl exec -it downward -- sh

# cd /etc/downward/
# ls -l
# exit 
```

# Lab06C
# Step 
Exploring the Kubernetes REST API via curl

```sh
kubectl cluster-info
curl https://xxxxx-aks-dns-xxxxxxx.hcp.southeastasia.azmk8s.io:443 -k

kubectl proxy & 

curl localhost:8001
curl http://localhost:8001/apis/batch
curl http://localhost:8001/api/v1/nodes/node1.example.local

jobs 
kill %1 
```

# Lab06D
# Step 
Communication between a Pod and Kubernetes REST API 

```sh

kubectl apply -f crole.yaml

kubectl create clusterrolebinding reader-pod-admin --clusterrole=cluster-role --serviceaccount=default:default

kubectl create -f curl.yaml
kubectl exec -it curl -- sh
 # env | grep KUBERNETES_SERVICE
 # curl https://kubernetes
 # ls /var/run/secrets/kubernetes.io/serviceaccount/
 # export CURL_CA_BUNDLE=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
 # curl https://kubernetes
 # TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
 # curl -H "Authorization: Bearer $TOKEN" https://kubernetes
 # NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace) 
 # curl -H "Authorization: Bearer $TOKEN" https://kubernetes/api/v1/namespaces/$NS/pods
 # exit 
```

# Lab06E
* SubCommand to view Kubernetes Resources 

# Step 1 
```sh 
kubectl api-resources 

kubectl api-versions

kubectl config view

```

# Step 2 
* Run Simple Python Program to access Kubernetes API and List running Pods and IP address on All Namespace

```sh 

cat kubepython.py 

pip install kubernetes 

python kubepython.py

```

# Lab06F
* Create CRD ( Custom Resource Definitions  )
* Explore the source code in web-controller-source 

```sh 

kubectl create serviceaccount website-controller 
*Service Account and ClusterRoleBinding is needed by website-controller because kubernetes in Azure are RBAC enabled

kubectl create clusterrolebinding website-controller --clusterrole=cluster-admin --serviceaccount=default:website-controller
*Service Account and ClusterRoleBinding is needed by website-controller because kubernetes in Azure are RBAC enabled

kubectl apply -f website-crd.yaml 

kubectl get crd 

kubectl apply -f website-controller.yaml 

kubectl get deployment 

kubectl get pod | grep website-controller 

kubectl apply -f stvweb1-website.yaml 
```
END