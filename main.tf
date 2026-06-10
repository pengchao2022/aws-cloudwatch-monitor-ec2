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

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGItthHZvUum/HO2EKun7jkPUvDUkc6ZjQ0P6LfVRm8iyosphuOxBEA7pQUt3cldYnzyC5u5zwQ+zL8/2SmGZwfUsk3L0pGMSzWaA3fmGcCVj3vkH4BINQ1UWI7RPE04/UUAv/LLecwKS+q7lubugJKNpuyrt027U+1a5FcKcKurK/MrCLx9UaQ08cFYORrddx/qcfIwTPvsAjRNldaZpU+q+Nl0GCHDi+RJlm5ZlOfi7XQ0BznPpQezAVT4DcFU50hCzkDLTwo7/1kPkdO3OG5pysS75S5t2OnKPbZWGqdhjiUX6KdoXOMjaoZC6rwegChrgjrKvtfg5MPXT8FWbCkCBV/I/0D0/yTthe8bmHX9PyUG8VztfT5D795biCRZx06ZyRNfAUXCLCG//5AbTezMTxfCkNkC8O3xDKuy6A/Aj5jWMldlLbxpXoAddidiLttpeMV+ROTHNmHqoN/i65Mb8+Ovet1WgWX2HG0u5S2T0pSz9jZJNWf69GSMp/ZtQri4+KZ4dMdO+rUTxfnKa7oH4rblYVjAF0ENUNT9T+S6nXhmr3qV2gnXS/KTREYoi1InwZCA0cKiJq+sWRtO02tao662dW4BCYwOer8gojBMERY2aZ6d24yeyLVcI+9C4GYnqDz+zw1L2CdPi0EraP8xP9zpeux1J8pFV95pFWIw== pengchao.ma2@outlook.com"

  instance_count = 1

  ami_id = "ami-091138d0f0d41ff90"

  instance_type = "t3.micro"
  
}

