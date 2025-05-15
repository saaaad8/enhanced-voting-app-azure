# Terraform Configuration for Example Voting App on Azure

This directory contains Terraform configuration to deploy the Example Voting App on Azure infrastructure. It provides two deployment options:

1. **Single VM Deployment** (main.tf): Deploys all components on a single VM
2. **Microservices Deployment** (advanced-setup.tf): Deploys each component on a separate VM

## Resources Created

### Common Resources (Both Deployments)
- Resource Group
- Virtual Network and Subnet
- Network Security Group with rules for SSH, HTTP, and app-specific ports
- Storage Account for diagnostics

### Single VM Deployment
- Public IP Address
- Network Interface
- Managed Disk for PostgreSQL data persistence
- Linux Virtual Machine with Docker and Docker Compose pre-installed

### Microservices Deployment
- 5 VMs (vote, result, worker, redis, postgres)
- 2 Public IP Addresses (vote, result)
- 5 Network Interfaces
- Managed Disk for PostgreSQL data persistence

## Prerequisites

1. [Terraform](https://www.terraform.io/downloads.html) installed (v1.0.0 or newer)
2. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
3. An Azure account with an active subscription
4. SSH key pair (if you don't have one, generate using `ssh-keygen -t rsa -b 4096`)

## Deployment Instructions

1. Log in to Azure using the Azure CLI:
   ```
   az login
   ```

2. Initialize Terraform:
   ```
   cd terraform
   terraform init
   ```

3. Choose your deployment option:

   ### Option 1: Single VM Deployment
   
   This deploys all components on a single VM (simpler but less scalable):
   
   ```
   # Comment out the advanced-setup.tf file to disable it
   mv advanced-setup.tf advanced-setup.tf.disabled
   
   # Review the deployment plan
   terraform plan
   
   # Apply the configuration
   terraform apply
   ```

   ### Option 2: Microservices Deployment
   
   This deploys each component on a separate VM (more complex but more scalable):
   
   ```
   # Make sure advanced-setup.tf is enabled
   mv advanced-setup.tf.disabled advanced-setup.tf 2>/dev/null || true
   
   # Review the deployment plan
   terraform plan
   
   # Apply the configuration
   terraform apply
   ```

4. When prompted, enter `yes` to confirm the deployment.

5. After deployment completes (approximately 10-15 minutes), Terraform will output:
   - For single VM: The public IP address of the VM and SSH command
   - For microservices: URLs for the vote and result applications

## Accessing the Application

Once deployment is complete:

### Single VM Deployment
- Vote application: http://<vm_public_ip>:8080
- Results application: http://<vm_public_ip>:8081

### Microservices Deployment
- Vote application: http://<vote_vm_public_ip>:8080
- Results application: http://<result_vm_public_ip>:8081

The exact URLs will be provided in the Terraform outputs after deployment.

## Customization

You can customize the deployment by modifying the variables in `variables.tf` or by providing values at runtime:

```
terraform apply -var="prefix=myapp" -var="location=westus2"
```

## Cleanup

To remove all resources created by this Terraform configuration:

```
terraform destroy
```

When prompted, enter `yes` to confirm the deletion of resources.
