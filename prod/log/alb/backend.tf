terraform {
  backend "s3" {
    bucket = "project-prod-shop-040602"
    key    = "project/prod/log_alb_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}