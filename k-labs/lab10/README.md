
# Lab10A
# Step 
Using a StatefulSet

```sh
kubectl get pv,pvc

kubectl get pod

kubectl get statefulsets

kubectl apply -f kubia-service-headless.yaml

kubectl apply -f kubia-statefulset.yaml

kubectl get pv,pvc

kubectl get pod 

kubectl get statefulsets

kubectl get pods --watch

kubectl apply -f kubia-service-public.yaml

**Playing with your Pods 
kubectl get svc

**Hit the pods
curl (kubiapet-public External IP address)

**post some data
curl -X POST -d "DataCON pan pan pan" (kubiapet-public IP address)
curl (kubiapet-public IP address)

**Directly post data to pods
kubectl get pod -o wide

kubectl exec -it jump1 -- sh
# curl (kubia-0 IP):8080
# curl -X POST -d "DATA: Jedi" (kubia-0 IP):8080
# curl (kubia-0 IP):8080
# exit

kubectl exec -it jump1 -- sh
# curl (kubia-1 IP):8080
# curl -X POST -d "DATA: Sith" (kubia-1 IP):8080
# curl (kubia-1 IP):8080
# exit

curl (kubiapet-public IP address)

```
* Optional 
* Simulate POD failure
```sh 
kubectl get nodes 

kubectl get pods -o wide 

kubectl delete pods (the_SITH) --grace-period=0 --force
k get pods 
curl (kubia-public IP address)

**Simulate NODE failure ( DO NOT DO THIS ON PRODUCTION )
* find the node that is running the kubiapet stateful pods, drain that pod

kubectl get pods -o wide 

kubectl drain (node-name) --force --delete-local-data --ignore-daemonsets

kubectl get pods -o wide

**Bring back the node
kubectl uncordon (node-name)
```

# Please clean up before moving to next LAB
```sh
kubectl get statefulsets

kubectl delete -f kubia-statefulset.yaml

kubectl delete -f kubia-service-headless.yaml

kubectl delete -f kubia-service-public.yaml
```

# Lab10B
- Running MySQL Replication with Stateful Sets (Single Master (rw) with Slave(ro) )
- refer: https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/

# Steps
```sh
kubectl apply -f mysql-configmap.yaml

kubectl get cm

kubectl apply -f mysql-services.yaml

kubectl get svc

kubectl apply -f mysql-statefulset.yaml 

kubectl get pods -l app=mysql --watch

** Create some DATA
kubectl exec -it mysql-0 -- bash 

# mysql 
# mysql> CREATE DATABASE test;
# mysql> CREATE TABLE test.messages (message VARCHAR(250));
# mysql> INSERT INTO test.messages VALUES ('hello');
# mysql> SELECT * from test.messages;
# mysql> exit
# exit 


** Create some data on READ only POD/Service -- it will fail 
kubectl exec -it mysql-1 -- bash 

# mysql 
# mysql> CREATE DATABASE test;
# mysql> SELECT * from test.messages;
# mysql> exit
# exit 


kubectl exec -it mysql-0  -- mysql
mysql> SELECT * FROM test.messages; 
mysql> exit; 

kubectl exec -it mysql-1  -- mysql
mysql> SELECT * FROM test.messages; 
mysql> exit; 

kubectl create  -f mysql-client.yaml

kubectl exec -it mysql-client -- bash

# root@mysql-client:/# mysql -h mysql-read -e "SELECT @@server_id,NOW()"
# root@mysql-client:/# exit


**Scale the statefulsets
kubectl get statefulsets.apps

kubectl scale statefulset --replicas=3 mysql
kubectl get pod --watch

kubectl exec -it mysql-2  -- mysql
mysql> SELECT * FROM test.messages; 
mysql> exit; 


kubectl scale statefulset --replicas=2 mysql

kubectl exec -it mysql-0  -- mysql
mysql> SELECT * FROM test.messages; 
mysql> exit; 

kubectl exec -it mysql-1  -- mysql
mysql> SELECT * FROM test.messages;
mysql> exit;


kubectl get pv
kubectl get pvc -l app=mysql


```
# Please clean up 
```sh
kubectl get statefulsets

kubectl delete statefulsets.apps mysql

kubectl get pods -l app=mysql 

kubectl get pv | grep mysql 

kubectl get pvc -l app=mysql 

kubectl delete pvc -l app=mysql

kubectl get pvc -l app=mysql 

kubectl delete svc -l app=mysql

kubectl delete cm -l app=mysql
```

# Lab10C - Operator
* Install MySQL Operator, Deploy Mysql HA and verify a MySql 3 Node Cluster Deployment 

```sh 
kubectl apply -f mysql-operator/deploy-crds.yaml

kubectl apply -f mysql-operator/deploy-operator.yaml

kubectl get deployment -n mysql-operator mysql-operator

kubectl create secret generic mypwds \
        --from-literal=rootUser=root \
        --from-literal=rootHost=% \
        --from-literal=rootPassword="REPLACE ME"


kubectl apply -f mysql-operator/sample-cluster.yaml

kubectl get innodbcluster --watch

kubectl get service mycluster

kubectl describe service mycluster

kubectl exec -it mysql-client -- bash 

bash# mysql -uroot -h IP_Address_MysqlCluster  -P6446 -p 
mysql> status ; 
mysql> exit ; 
bash# exit
```
END