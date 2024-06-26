terraform {
  required_version = ">= 1.5, < 1.6"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.11"
    }
  }
}
