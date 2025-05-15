# Enhanced Example Voting App

This project extends the original dockersamples/example-voting-app with advanced Kubernetes features and Infrastructure as Code (IaC) using Terraform for Azure deployment.

## Project Overview

The Example Voting App is a distributed application running across multiple containers:

* A Python web app for voting between two options
* A Redis queue for collecting votes
* A .NET worker for processing votes
* A PostgreSQL database for storing vote results
* A Node.js web app for displaying results

## Enhancements Made

### Kubernetes Enhancements

The original Kubernetes manifests have been enhanced with the following features:

1. **Resource Management**
   - Added resource requests and limits to all deployments
   - Ensures proper resource allocation and prevents resource starvation

2. **Health Monitoring**
   - Implemented liveness and readiness probes
   - Improves reliability by automatically restarting unhealthy containers

3. **Configuration Management**
   - Added ConfigMaps for application configuration
   - Separates configuration from code for better maintainability

4. **Security**
   - Implemented Secrets for sensitive information (database credentials)
   - Improves security by keeping sensitive data separate from code

5. **Auto-scaling**
   - Added Horizontal Pod Autoscaler (HPA)
   - Automatically scales the application based on CPU/memory usage

6. **Network Security**
   - Implemented Network Policies
   - Restricts communication between pods for improved security

7. **High Availability**
   - Added Pod Disruption Budget (PDB)
   - Ensures application availability during cluster maintenance

8. **Local Development**
   - Created script to build Docker images locally
   - Modified deployment files to use local images with `imagePullPolicy: Never`

### Infrastructure as Code with Terraform

Added Terraform configuration to deploy the application on Azure:

1. **Azure Infrastructure**
   - Resource Group for organizing all resources
   - Virtual Network and Subnet for network isolation
   - Network Security Group with appropriate security rules
   - Static Public IP for reliable access
   - Storage Account and Managed Disk for persistent data

2. **Virtual Machine**
   - Ubuntu VM with Docker pre-installed
   - Cloud-init script for automatic application deployment
   - Managed disk attachment for PostgreSQL data persistence

3. **Deployment Options**
   - Single VM deployment for simplicity and cost-effectiveness
   - (Optional) Multi-VM microservices deployment for production scenarios

## Deployment Options

### 1. Docker Compose (Local Development)

For local development and testing:

```shell
docker compose up
```

Access the applications at:
- Vote app: http://localhost:8080
- Results app: http://localhost:8081

### 2. Docker Swarm

For a simple container orchestration:

```shell
docker swarm init
docker stack deploy --compose-file docker-stack.yml vote
```

### 3. Enhanced Kubernetes Deployment

The `k8s-specifications` folder contains enhanced YAML manifests with advanced Kubernetes features.

```shell
# Deploy all components
kubectl create -f k8s-specifications/

# Check the status of deployments
kubectl get pods

# Access the applications
# Vote app is available on port 31000 on each cluster node
# Result app is available on port 31001 on each cluster node
```

To remove the Kubernetes deployment:

```shell
kubectl delete -f k8s-specifications/
```

#### Key Kubernetes Features

- **View the HPA configuration:**
  ```shell
  kubectl get hpa
  ```

- **View the ConfigMap:**
  ```shell
  kubectl get configmap voting-app-configmap -o yaml
  ```

- **View the Secret:**
  ```shell
  kubectl get secret db-secret -o yaml
  ```

- **View Network Policies:**
  ```shell
  kubectl get networkpolicies
  ```

### 4. Azure Deployment with Terraform

The `terraform` directory contains IaC configuration to deploy on Azure:

```shell
# Navigate to the terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Apply the configuration
terraform apply
```

After deployment completes (5-10 minutes), Terraform will output:
- The public IP address of the VM
- SSH command to connect to the VM

Access the applications at:
- Vote app: http://<vm_public_ip>:8080
- Results app: http://<vm_public_ip>:8081

To destroy the Azure infrastructure:

```shell
terraform destroy
```

## Architecture

![Architecture diagram](architecture.excalidraw.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time

## Project Structure

```
├── k8s-specifications/       # Enhanced Kubernetes manifests
│   ├── db-deployment.yaml    # PostgreSQL deployment
│   ├── db-pvc.yaml           # Persistent Volume Claim for PostgreSQL
│   ├── db-secret.yaml        # Secret for database credentials
│   ├── network-policy.yaml   # Network security policies
│   ├── vote-hpa.yaml         # Horizontal Pod Autoscaler
│   ├── vote-pdb.yaml         # Pod Disruption Budget
│   └── voting-app-configmap.yaml # Application configuration
│
├── terraform/                # Azure Infrastructure as Code
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Variable definitions
│   ├── cloud-init.tpl        # VM initialization script
│   └── README.md             # Terraform-specific instructions
│
├── vote/                     # Python frontend application
├── result/                   # Node.js results application
├── worker/                   # .NET vote processor
├── seed-data/                # Test data generation scripts
└── build-images.sh           # Script to build local Docker images
```

## Customization Options

### Kubernetes Customization

- **Resource Allocation**: Modify CPU/memory requests and limits in deployment YAML files
- **Scaling Parameters**: Adjust HPA min/max replicas and CPU threshold in vote-hpa.yaml
- **Network Policies**: Customize allowed traffic patterns in network-policy.yaml
- **Application Config**: Update application settings in voting-app-configmap.yaml

### Terraform Customization

- **VM Size**: Change the VM size in variables.tf for different performance tiers
- **Region**: Modify the Azure region in variables.tf for geographic deployment
- **Storage**: Adjust the disk size for PostgreSQL data in main.tf
- **Network**: Customize network rules in the Network Security Group section

## Notes

The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.

This enhanced version demonstrates how to apply DevOps best practices to a simple distributed application, showcasing both container orchestration with Kubernetes and infrastructure automation with Terraform.
