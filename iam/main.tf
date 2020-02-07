provider "aws" {
    region = var.region
    profile = "default"
}
module "iam" {
  source = "../modules/iam"
  instance_profile = var.instance_profile
  iam_role = var.iam_role
  iam_policy =  var.iam_policy
  policy_attachment = var.policy_attachment
}