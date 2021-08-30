terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.56.0"
    }
  }

  backend "s3" {
    bucket = "cloudtitlan-rts-tf-state"
    key    = "k8s-manual/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}