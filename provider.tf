terraform {
  required_providers { #Each provider has individual block.
    aws = {
      source = "hashicorp/aws"
      #version = "!=5.31.0"
      #version = "~>5.31.0"
      version = ">=5.31.0"
    }
    google = {
      }
                    }
  backend "local"{
      path="terraform.tfstate"
    }
  }
############################Now you add provider block###############
provider "aws" { #Provider related configuration.
  region = var.region
}