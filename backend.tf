terraform {
  required_version = ">=0.14.0"
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-west-2"
    profile = "default"
    key     = "terraform-statefile-la-tutorial"
    bucket  = "dyx-terraform-tfstates"
  }
}   