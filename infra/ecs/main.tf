terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.56"
    }
  }

  backend "s3" {
    bucket = "cloudtitlan-rts-tf-state"
    key    = "ecs/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}
