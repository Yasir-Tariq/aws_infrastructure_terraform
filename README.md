# Terraform-VPC
Provisioning AWS Virtual Private Cloud and compute resources along with other necessary resources using Terraform.


## Version

Terraform v0.12.18
provider.aws v2.47.0



## Child Modules
This repository consists of five child modules which are as follows:

1.alb_tg: contains an application load balancer and a target group.

2.asg-lc: contains an autoscaling group and a launch configuration.

3.ec2:    contains an EC2 instance.

4.iam:    contains a role for s3 access along with a policy and an instance_profile.

5.vpc:    contains a vpc along with other related resources.

Also,there is directory named "templates" which contains userdata files used in the scenario.

## Parent Modules

This repository consists of three parent modules which are as follows:

1.base_infra: represents the independent infrastructure(vpc).

2.compute:    represents compute resources such as ec2,alb,asg etc.

3.iam:        represents iam role and policy.

base_infra and iam are independent modules where as compute module is dependent on both other
modules. So, keep the sequence in mind.

## Explanation

Infrastructure is all parametrised based on user values which can be stored in a tfvars file.
Public subnets are created dynamically based on the number of availability zones provided by
the user. Terraform state is maintained in a s3 bucket. All the parent modules have their own
separate Terraform state files. Moreover, a Dynamodb could be provisioned before hand to ensure
state locking, which means that only one user is allowed at a time to access the state to avoid
conflict. All the code is in accordance with selected Terraform workspace so that we can have two
or more setups with multiple workspaces. Outputs are exported and are used in the form of locals
specifically in the compute's main.tf file. Moreover, two terraform_remote_state data resources
are defined to fetch the network and iam state from the s3 bucket.

## Required Commands

### Terraform
    terraform init:     Initialize a Terraform working directory.
    terraform validate: Checks for configuration validity.
    terraform plan:     Generate and show an execution plan.
    terraform apply:    Builds or changes infrastructure.
    terraform destroy:  Destroy Terraform-managed infrastructure.

### workspace
    terraform workspace new sample:     Creates a new workspace named sample and switches to it.
    terraform workspace list:           Lists all the workspaces.
    terraform workspace select sample:  selects a specific workspace.
    terraform workspace delete sample:  Deletes a specific workspace.
