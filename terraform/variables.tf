variable "prefix" {
  description = "Prefix for all resources"
  default     = "votingapp"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "voting-app-rg"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  default     = "eastus"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM for single VM deployment"
  default     = "Standard_DS2_v2"
  type        = string
}

variable "vote_vm_size" {
  description = "Size of the VM for vote frontend"
  default     = "Standard_B1ms"
  type        = string
}

variable "result_vm_size" {
  description = "Size of the VM for result app"
  default     = "Standard_B1ms"
  type        = string
}

variable "worker_vm_size" {
  description = "Size of the VM for worker"
  default     = "Standard_B1ms"
  type        = string
}

variable "redis_vm_size" {
  description = "Size of the VM for Redis"
  default     = "Standard_B1ms"
  type        = string
}

variable "postgres_vm_size" {
  description = "Size of the VM for PostgreSQL"
  default     = "Standard_B1ms"
  type        = string
}

variable "admin_username" {
  description = "Username for the VM"
  default     = "azureuser"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  default     = "~/.ssh/id_rsa.pub"
  type        = string
}
