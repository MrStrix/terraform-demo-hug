variable "location" {
  default = "westeurope"
}

variable "username" {
  default = "adfinis"
}

resource "azuread_application" "aks-tenant" {
  name            = "app-aks-tenant-demo-meetup"
  identifier_uris = ["https://adfinis-kubernetes-hug"]
}

resource "azuread_service_principal" "aks-tenant" {
  application_id = azuread_application.aks-tenant.application_id
}

resource "random_string" "sp_password" {
  length = 32
}

resource "azuread_service_principal_password" "aks-tenant" {
  service_principal_id = azuread_service_principal.aks-tenant.id
  value                = random_string.sp_password.result
  end_date             = "2020-04-04T01:02:03Z"
}

module "kubernetes" {
  source = "./modules/terraform-azurerm-aks"

  prefix             = "prefix"
  location           = var.location
  kubernetes_version = "1.13.5"
  admin_username     = var.username

  CLIENT_ID     = azuread_service_principal.aks-tenant.application_id
  CLIENT_SECRET = random_string.sp_password.result
}

output "kubeconfig" {
  value = module.kubernetes.kube_config_raw
}
