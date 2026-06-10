variable "aws_region" {
  description = "The region for AWS resources to deploy"
  type        = string
  default     = "us-east-1"
  
}

variable "ssh_public_key" {
  description = "The id_rsa.pub file key to ssh the EC2 instance"
  type        = string
  default     = ""
  
}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
  default     = 1
  
}