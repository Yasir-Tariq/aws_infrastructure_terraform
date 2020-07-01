data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-yasir"
    key    = "network/${terraform.workspace}/terraform.tfstate"
    region = "us-east-2"
  }
}
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "terraform-state-yasir"
    key    = "iam/${terraform.workspace}/terraform.tfstate"
    region = "us-east-2"
  }
}