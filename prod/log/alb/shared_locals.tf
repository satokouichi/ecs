locals {
  name_prefix  = "${local.system_name}-${local.env_name}"
  system_name  = "project"
  env_name     = "prod"
  service_name = "shop"
}