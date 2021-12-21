# Lab05-Extra
# Step 1

Create kubernetes secrets in new namespace 

```sh
kubectl create namespace sec-ns

kubectl create secret generic mysecret --from-literal user=myuser \ 
--from-literal password=redhat123 --from-literal database=test_sec --from-literal hostname=mysql -n sec-ns

kubectl get secrets -n sec-ns

```

# Step 2
Create Database kubernetes deployments 

```sh
kubectl create deployment mysql --image=stv707/mysql-57:5.7-47 --port=3306 -n sec-ns

kubectl -n sec-ns get pod

kubectl -n sec-ns logs mysql-xxxxx

```

# Step 3
Inject secrets to database deployment using prefix 

```sh
kubectl set env deployment/mysql --from secret/mysql --prefix MYSQL_ -n sec-ns

kubectl apply -f mysql-svc.yaml 

kubectl -n sec-ns get pod

kubectl exec -it -n sec-ns mysql-xxxxx -- bash

bash-4.2$ env | grep MYSQL

bash-4.2$ mysql -u myuser --password=redhat123 test_sec -e 'show databases;'

bash-4.2$ exit

```

# Step 4
Create App Kubernetes Deployment 


```sh
kubectl create deployment quotes --image=stv707/famous-quotes:1.0 --port=8000 -n sec-ns

kubectl get pod -n sec-ns

```

# Step 5
Inject secrets to app deployment using prefix 

```sh

kubectl set env deployment/quotes --from secret/mysecret --prefix QUOTES_ -n sec-ns

```

# Step 6 
Expose App service 
```sh 

kubectl apply -f quotes-svc.yaml

```

# Step 7 
Access app via web browser 

```sh 
kubectl -n sec-ns get all

kubectl -n sec-ns get service quotes

curl -s  http://<EXTERNAL-IP>/env

curl http://<EXTERNAL-IP>/status

curl http://<EXTERNAL-IP>/random

```

# Step 8 
CleanUp 
```sh 
kubectl  -n sec-ns get all

kubectl  -n sec-ns get secrets

kubectl delete namespaces sec-ns

```

END