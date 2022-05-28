data "aws_kms_alias" "rds" {
  name = "alias/aws/rds"
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/network_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}