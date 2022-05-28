terraform {
  backend "s3" {
    bucket = "portfolio-2022-ecdemo-ver1"
    key    = "project/prod/ecr_v1.0.0.tfstate"
    region = "ap-northeast-1"
  }
}