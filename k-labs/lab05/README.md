# Lab05A
# Step 
* Passing an argument in the pod definition

* Run the below statements, then edit the manifest and change the ARG value and rerun 
```sh
cat fortune-args/fortuneloop.sh

cat fortune-pod-args.yaml
**You can change the ARG Value.

kubectl apply -f fortune-pod-args.yaml

kubectl get pods -o wide
*note ip address of fortune2s

kubectl exec -it jump1 -- sh
# curl <ip_address_pod>
# watch -n1 curl <ip_address_pod> 
# exit 

kubectl delete -f fortune-pod-args.yaml
```

# Lab05B
# Step 
Setting environment variables for a container

```sh
cat fortune-env/fortuneloop.sh
cat fortune-pod-env.yaml 
kubectl create -f fortune-pod-env.yaml

kubectl get pods -o wide

kubectl exec -it jump1 -- sh
# curl <ip_address_pod>
# watch -n1 curl <ip_address_pod> 
# exit 
```

# Lab05C
# Step 
Creating ConfigMaps 

```sh
kubectl create -f fortune-config.yaml
kubectl get configmaps
kubectl get configmaps fortune-config -o yaml 

cat fortune-pod-env-configmap.yaml
kubectl create -f fortune-pod-env-configmap.yaml

kubectl get pods -o wide

kubectl exec -it jump1 -- sh
# curl <ip_address_pod>
# watch -n1 curl <ip_address_pod> 
# exit 
```

# Lab05D
# Step 
ConfigMap volume 


```sh
kubectl delete configmap fortune-config

ls -l ./configmap-files
cat configmap-files/my-nginx-config.conf
cat configmap-files/sleep-interval

kubectl create configmap fortune-config --from-file=configmap-files
kubectl get configmap fortune-config -o yaml

cat fortune-pod-configmap-volume.yaml
kubectl create -f fortune-pod-configmap-volume.yaml

kubectl get pods  -o wide

kubectl exec -it jump1 -- sh
# curl -H "Accept-Encoding: gzip" -I <POD_IP_Address>
# exit 

kubectl exec fortune-configmap-volume -c web-server -- ls /etc/nginx/conf.d

kubectl exec fortune-configmap-volume -c web-server -- ls /tmp/whole-fortune-config-volume

```
# Lab05E
# Step
Creating Secrets <br>
Create your own little Secret. You’ll improve your fortune-serving Nginx <br>
container by configuring it to also serve HTTPS traffic. For this, you need to create a<br>
certificate and a private key. The private key needs to be kept secure, so you’ll put it<br>
and the certificate into a Secret. <br>

```sh
kubectl delete configmap fortune-config

cd fortune-https/ 

openssl genrsa -out https.key 2048

openssl req -new -x509 -key https.key -out https.cert -days 3650 -subj /CN=www.kubia-example.com

kubectl create secret generic fortune-https --from-file=https.key --from-file=https.cert --from-file=foo

kubectl get secret fortune-https -o yaml

ls -l ./configmap-files-https

cat configmap-files-https/my-nginx-config.conf

cat configmap-files/sleep-interval

kubectl create configmap fortune-config --from-file=configmap-files-https

kubectl  create -f fortune-pod-https.yaml

kubectl get pods -o wide

kubectl exec -it jump1 -- sh
 # curl   https://<fortune-https_pod_ip> -k 
 # curl   https://<fortune-https_pod_ip> -k -v 
 # exit 

kubectl exec fortune-https -c web-server -- mount | grep certs
```
END