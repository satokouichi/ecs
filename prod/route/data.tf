data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/network_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "ec2" {
  backend = "s3"

  config = {
    bucket = "project-prod-shop-040602"
    key    = "${local.system_name}/${local.env_name}/ec2_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}
