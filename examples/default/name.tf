module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact     = "nobody@dell.org"
  environment = "sbx"
  location    = local.location
  program     = "dyl"
  repository  = "terraform-azurerm-log-analytics-workspace"
  workload    = "tfc-agent"
}