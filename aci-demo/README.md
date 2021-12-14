## Deploy ACI Group on Azure - DEMO

1. Modify/View acideploy.json file or just use the sample image provided 

2. Run the following command to create Azure RG in Azure Cloud Shell 

```sh 
az group create --name aci-demo-rg --location southeastasia
```

3. Deploy the .json template 
```sh 
az deployment group create --resource-group aci-demo-rg --template-file acideploy.json
```

4. View the state of the deployment
```sh 
az container show --resource-group aci-demo-rg --name myContainerGroup --output table
```