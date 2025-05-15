# Terraform Configuration for Example Voting App on Azure (Single VM Deployment)

This Terraform configuration deploys the **Example Voting App** on Azure infrastructure using a **single virtual machine (VM)**.

## Resources Deployed

- Resource Group
- Virtual Network and Subnet
- Network Security Group with rules for SSH, HTTP, and app-specific ports (8080, 8081)
- Storage Account for diagnostics
- Public IP Address
- Network Interface
- Managed Disk for PostgreSQL data persistence
- Linux Virtual Machine with Docker and Docker Compose pre-installed

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or newer
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An Azure account with an active subscription
- SSH key pair (Generate one if needed using: `ssh-keygen -t rsa -b 4096`)

## Deployment Instructions

1. **Log in to Azure using the Azure CLI:**
   ```bash
   az login
   ```

2. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   ```

3. **Apply the Terraform configuration:**
   ```bash
   terraform apply
   ```

4. **Confirm the deployment** by typing `yes` when prompted.

5. **After deployment completes** (approx. 10–15 minutes), Terraform will output:
   * The public IP address of the VM
   * The SSH command to connect to the VM

## Accessing the Application

Once the deployment is complete:

* **Vote application:** `http://<vm_public_ip>:8080`
* **Results application:** `http://<vm_public_ip>:8081`

You'll find the exact public IP address in the Terraform output.

## Customization

You can customize the deployment by modifying variables in `variables.tf` or by providing them at runtime:

```bash
terraform apply -var="prefix=myapp" -var="location=westus2"
```

## Cleanup

To remove all resources created by this Terraform configuration:

```bash
terraform destroy
```

Type `yes` when prompted to confirm deletion.
