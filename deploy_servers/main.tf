variable "server_count" {
  default = 1
}

variable "location" {
  default = "westeurope"
}

provider "azurerm" {}

module "servers" {
  source  = "Azure/compute/azurerm"
  version = "~> 1.2"

  nb_instances   = "${var.server_count}"
  location       = "${var.location}"
  vm_os_simple   = "CentOS"
  vnet_subnet_id = "${module.network.vnet_subnets[0]}"
  public_ip_dns  = ["hugdemovm"]
}

module "network" {
  source  = "Azure/vnet/azurerm"
  version = "~> 1.2"

  location        = "${var.location}"
  address_space   = "10.0.0.0/16"
  subnet_prefixes = ["10.0.1.0/24"]
  subnet_names    = ["subnet1"]
}

output "vm_name" {
  value = "${module.servers.public_ip_dns_name}"
}
