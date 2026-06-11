# aws-cloudwatch-monitor-ec2
In this demo, I will write terraform modules for EC2, VPC and Security Group to create EC2 instannce and also installed CWA cloudwatch agent to monitor EC2 memory usage and create alram in Cloudwatch that will send notification to you when memory above the baseline 


## Features

- enabled backend s3 to store terraform statefile and use dynamodb_table to lock the statefile and prevent multiple people or process from modifying your infrastructure simultaneously

- enabled github actions workflow deploy.yaml to run terraform to deploy the whole infrastructure when PR merged to main

- enabled github actions workflow destroy.yaml to run terraform destroy to remove all the resources manaually

- passing id_rsa.pub to parameter ssh_public_key when instance creating so that will skip password when user try to SSH the server

- created multiple public subnets and private subnets to make sure high avaialability

## Usage

- pass the values from main.tf in the repo root

```shell
provider "aws" {
  region = "us-east-1"
  
}

# create VPC
module "vpc" {
  source = "./modules/vpc"
  
}

# create sg
module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  
}

# create EC2 instances
module "ec2" {
  source = "./modules/ec2"

  subnet_ids = module.vpc.public_subnet_ids

  security_group_ids = [module.sg.sg_id]

  key_name  = "my-key"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGItthHZvUum/J8pFV95pFWIw== pengchao.ma2@outlook.com"

  instance_count = 1

  ami_id = "ami-091138d0f0d41ff90"

  instance_type = "t3.micro"
  
}

```


