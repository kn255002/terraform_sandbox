terraform {
  required_providers { #Each provider has individual block.
    aws = {
      source = "hashicorp/aws"
      #version = "~> 5.0.0"
    }
  }
}
############################Now you add provider block###############
provider "aws" { #Provider related configuration.
  region = var.region
}