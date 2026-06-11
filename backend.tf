terraform {
  backend "s3" {

    bucket = "pengchao2022-terraform-state"

    key = "ec2-cloudwatch/terraform.tfstate"
    
    
    region = "us-east-1"
    
    use_lockfile = true

    encrypt = true
  }
}