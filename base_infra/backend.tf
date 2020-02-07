terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-yasir"
    dynamodb_table = "dynamodb-terraform-state-lock"
    region = "us-east-2"
    key = "terraform.tfstate"
    workspace_key_prefix = "network"
  }
}