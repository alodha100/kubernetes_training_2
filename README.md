# Kube_training
Kube Training Assets

- This Hub contains the Scripts/JSON files to provision Kubernetes Cluster and Labs files needed for training

- This Scriplet/JSON files can be only used in MS Azure Cloud

- Scriplet available in this Hub will use Azure Resource Manager(ARM) Template to create Kubernetes Cluster.

- The only script you need to run is main.sh

- main.sh will call all the other scripts automatically

# Steps to be Performed on Azure Cloud Shell: 

# Start
1. Go to Azure Shell - Bash
2. use git clone to clone this HUB
  
   ```sh 
   git clone https://github.com/stv707/kubernetes_training_2.git
   ```

3. Change Directory to hub directory  

   ```sh 
   cd kubernetes_training_2/
   ```

4. Execute main.sh with aks as argument 
   ```sh 
   bash main.sh aks
   ```
   **NOTE**
   - You need to pass aks as an argument
   - aks arg will create Azure Kubernetes Service

5. Wait until the deployment is done. Then, Execute this to reveal Vital Info of AKS: 
   ```sh 
   bash main.sh info 
   ```
   **NOTE**
   - Write down the vital info for future usage
   - Vital info will be recorded in file aks_info.txt as well, ``` cat $HOME/aks_info.txt ```

6. Deploy vm001 for External Service 
   ```sh 
   bash main.sh vm001 
   ```
   **NOTE**
   - You need to pass vm001 as argument
   - vm001 arg will create additional vm for external service
   - You No need to wait for this deployment
# END

Thank You, Have Fun, Cheers<br>
Steven<br>
smahalin@redhat.com

* Hub Will go Private on 16th Sept 2022 @ 8pm 