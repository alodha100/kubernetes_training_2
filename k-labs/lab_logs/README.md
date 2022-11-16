#  Explore Pod Logging


Single Pod Logging
# Step 1 

Access Azure Cloud Shell and Connect to AKS

- Initiate Azure Cloud Shell ( you may be asked to create storage account when you run Azure Cloud Shell for First time, accept the default)

- Run the following command on Azure Cloud Shell

```sh
kubectl apply -f counter-pod.yaml

kubectl logs counter

kubectl delete pod counter --force 

```

# Step 2 

Using Sidecar container to collect logs to a volume 

```sh
shell# kubectl apply -f two-files-counter-pod-streaming-sidecar.yaml

shell# kubectl get pod counter
NAME      READY   STATUS    RESTARTS   AGE
counter   3/3     Running   0          16s

shell# kubectl logs counter count-log-1

shell# kubectl logs counter count-log-2

shell# kubectl delete pod counter --force
```