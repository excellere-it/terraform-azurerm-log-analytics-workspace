module "name" {
  source = "../../../terraform-terraform-namer"

  contact     = "nobody@dell.org"
  environment = "sbx"
  location    = local.location
  repository  = "terraform-azurerm-log-analytics-workspace"
  workload    = "tfc-agent"
}
