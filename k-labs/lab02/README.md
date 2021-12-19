#  Lab02 - Pods 

# Step 1 
Create and Verify Single Container Pod 

```sh
 kubectl create -f kubia-pod.yaml
 
 kubectl get po kubia-pod -o yaml
 
 kubectl get po kubia-pod -o json
 
 kubectl get pods

 kubectl get pods -o wide

 kubectl create -f box1.yaml

 kubectl create -f box2.yaml

 kubectl get pods -o wide
```

# Step 2 
Create and Verify Multi Container Pod ( init container )

```sh
kubectl create -f kubia-pod-init-multi.yaml

kubectl get pod kubia-pod-init -w
**As per kubia-pod-init-multi.yaml manifest, init container runs sleep command for 90 second, after 90 Second, the main container will start
```

# Step 3 
Create and Verify Multi Container Pod ( sidecar container )

```sh
kubectl create -f kubia-pod-sidecar-multi.yaml

kubectl get pod
** Note from output there is 2/2 in READY state for sidecar-container-demo

kubectl get pod -o wide
** NOTE the IP address of sidecar-container-demo 

kubectl exec -it box1 -- sh 
# curl IP_sidecar-container-demo 
# exit 

kubectl delete -f kubia-pod-sidecar-multi.yaml
```

# Step 4 
Inter-Pod Networking  

```sh

kubectl get pod -o wide 

** Note the IP address of kubia-pod 
** Open another terminal(Azure Cloud Shell) to perform next step 

kubectl exec -it box1 -- sh 
# curl http://IP_kubia_pod:8080
# exit 

kubectl exec -it box2 -- sh 
# curl http://IP_kubia_pod:8080
# exit 

```

# Step 5
Create pod with security context (runasuser/group) and verify the pod user/group context 

```sh

cat seccon1.yaml

kubectl apply -f seccon1.yaml 

kubectl get pod

kubectl exec -it seccon1 -- bash

seccon1:/$ id

seccon1:/$ ps aux

seccon1:/$ ls -ld /data/test

seccon1:/$ cd /data/test/

seccon1:/data/test$ echo "This file has the same GID as the parent directory" > demofile

seccon1:/data/test$ ls -l

seccon1:/data/test$ exit

kubectl delete -f seccon1.yaml 
```

# Step 6
Create pod with security context for pod level and container level and verify the pod user/group context 

```sh
cat seccon2.yaml

kubectl apply -f seccon2.yaml

kubectl get pods
** verify 2/2 is in READY state for pod seccon2 

kubectl exec -it seccon2 -c one -- sh

/ $ ps aux

/ $ id

/ $ cd /data/sec

/data/sec $ echo "data from con one pod seccon2" > one.data

/data/sec $ ls -l

/data/sec $ exit

kubectl exec -it seccon2 -c two -- sh

/ $ ps aux

/ $ id

/ $ cd /data/sec

/data/sec $ ls -l 

/data/sec $ cat one.data

/data/sec $ echo "overwrite" > one.data

/data/sec $ echo "data from con two pod seccon2" > two.data

/data/sec $ ls -l

/data/sec $ exit

kubectl delete -f seccon2.yaml

```

# Step 7
Verify securityContext Linux Kernel capabilities ( drop all )

```sh
kubectl get pod
** Make sure kubia-pod still running 

cat seccon3.yaml

kubectl apply -f seccon3.yaml

kubectl get pod -o wide
** note the kubia-pod IP address 

kubectl exec -it seccon3 -- sh

/ # capsh --print
** note: there is no capability granted for this container 

/ # id
** note: the container is running as root

/ # ps aux
** process running under root 

/ # ping <kubia-pod IP>
** ping another container, it should failed, because container do not have network capability 

/ # apk add bash
** install software inside container, it should fail, because filesystem/permission capability not granted

/ # curl <kubia-pod-ip>:8080
** software connection works, API, external access will work, underlying kernel capability is disabled ( secure run )

/ # exit

```


# Step 8
Verify securityContext Linux Kernel capabilities ( allow limited )

```sh
kubectl apply -f seccon4.yaml

kubectl get pod -o wide 

kubectl exec -it seccon4 -- sh

/ # id
** note: the container is running as root

/ # ps aux
** process running under root 

/ # capsh --print
** note: there is capability granted for this container 

/ # ping <kubia-pod IP>
** ping another container, it should work

/ # apk add bash
** install software inside container, it should install

/ # curl <kubia-pod-ip>:8080
** software connection works, API, external access will work

/ # exit

```

# Step 9
Delete/Remove pods

```sh

** Delete all pod to prepare for next lab

```

# Step 10 
If time permits, you may continue to extra lab 

```sh 
Proceed to lab02-extra if time permits 
```

END