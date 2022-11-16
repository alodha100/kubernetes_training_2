#  Explore HELM for Kubernetes


# Prerequisites

### The following prerequisites are required for a successful and properly secured use of Helm.

- A Kubernetes cluster
- Deciding what security configurations to apply to your installation, if any
- Installing and configuring Helm.

### Install Kubernetes or have access to a cluster
- You must have Kubernetes installed. For the latest release of Helm, we recommend the latest stable release of Kubernetes, which in most cases is the second-latest minor release.
- You should also have a local configured copy of kubectl.


# Step
```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami

$ helm search repo bitnami
NAME                             	CHART VERSION	APP VERSION  	DESCRIPTION
bitnami/bitnami-common           	0.0.9        	0.0.9        	DEPRECATED Chart with custom templates used in ...
bitnami/airflow                  	8.0.2        	2.0.0        	Apache Airflow is a platform to programmaticall...
bitnami/apache                   	8.2.3        	2.4.46       	Chart for Apache HTTP Server
bitnami/aspnet-core              	1.2.3        	3.1.9        	ASP.NET Core is an open-source framework create...
# ... and many more

$ helm repo update              # Make sure we get the latest list of charts

$ helm install bitnami/mysql --generate-name

$ helm list

```