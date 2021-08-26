terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "cloudtitlan-rts-tf-state"
  acl    = "private"

  versioning {
    enabled = true
  }
}