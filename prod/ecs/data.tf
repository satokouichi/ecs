data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/network_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/ecr_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "route" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/route_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}