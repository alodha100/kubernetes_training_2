# Lab09A
# Step 
Using Deployments for updating apps declaratively <br>
Open up 2 terminal connection to AKS <br>

Perform these steps on terminal 1 <br>
```sh

kubectl get svc 
 * remove unwanted svc 

kubectl delete rc --all
 * remove unwanted Replication Controller / ReplicaSets

cat kubia-deployment-and-service-v1.yaml

kubectl create -f kubia-deployment-and-service-v1.yaml --record
 * Be sure to include the --record command-line option when creating it.
 * This records the command in the revision history, which will be useful later.

kubectl get svc

kubectl get deployment

kubectl describe deployment

kubectl rollout status deployment kubia

kubectl get pod

kubectl get replicasets
```

Perform these steps on terminal 2 <br>
we will use a jump Pod to perform curl to service kubia to access the deployment <br>
```sh
  kubectl exec -it jump1 -- sh

  # while true; do curl http://kubia; echo ; sleep 5 ;  done
```

Perform these steps on terminal 1 <br>
```sh
kubectl set image deployment kubia nodejs=stv707/kubia:v2 --record
 * this will perform the update from v1 to v2 of the app

kubectl rollout history deployment kubia

kubectl get rs
``` 

# Lab09B
# Step
Rolling back a deployment<br>
Make sure Terminal 2 still running the while loop <br>

```sh
kubectl get pods

kubectl set image deployment kubia nodejs=stv707/kubia:v3 --record

kubectl rollout history deployment kubia

kubectl get rs
 * At this point only 1 rs will report with 3 ready Pods
 * Observe the terminal 2 , the app should report "Some internal error has occurred!" after 5 cycle of curl hit
 * Wait until all pod responds with "Some internal error has occurred!" before moving to next command 

kubectl rollout undo deployment kubia
 * this will undo the deployment of v3 and rolls back to v2 
 * Observe the terminal 2 , the app should report v2 is up and online

kubectl get rs 
 * v2 rs should report 3 pod ready 

kubectl rollout history deployment kubia

kubectl rollout undo deployment kubia --to-revision=1
 * This will roll back to revision 1 (recorded deployment ) and Terminal 2 should show app is now v1 
```

# Lab09C
# Step 
 * Controlling rollout using MaxSurge and MaxUnavailable
```sh 
kubectl delete deployments.apps kubia 

 * Stop the while loop on terminal 2 amd execute with sleep 1 
 # while true; do curl http://kubia; echo ; sleep 1 ;  done

kubectl apply -f kubia-deployment-and-service-v1.yaml --record 
 
 * You should see v1 app kubia running 3 pod on Terminal 2 


kubectl apply -f kubia-deployment-maxset-v4.yaml

```

# Lab09D
# Step 
Blocking rollouts with readinessProbe<br>
Make sure Terminal 2 still running the while loop<br>
```sh
kubectl delete deployments.apps kubia 

kubectl apply -f kubia-deployment-and-service-v1.yaml 

cat kubia-deployment-v3-with-readinesscheck.yaml

kubectl apply -f kubia-deployment-v3-with-readinesscheck.yaml

kubectl rollout status deployment kubia

kubectl get pods

kubectl rollout undo deployment kubia

kubectl rollout status deployment kubia

kubectl delete -f kubia-deployment-and-service-v1.yaml

```
You can control+c on terminal 2 to stop the while loop and issue exit.

END