module "web" {
  source = "../../modules/ecr"

  name = "${local.name_prefix}-${local.service_name}-web"
}

module "php" {
  source = "../../modules/ecr"

  name = "${local.name_prefix}-${local.service_name}-php"
}

module "db" {
  source = "../../modules/ecr"

  name = "${local.name_prefix}-${local.service_name}-db"
}