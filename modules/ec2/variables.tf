variable "ami_id" {
  description = "The amazon machine image ID e.g. Ubuntu 26.04 LTS"
  type        = string
  default     = "ami-091138d0f0d41ff90"
  
}


variable "instance_type" {
  description = "The type of instance e.g. t2.micro, t3.micro"
  type        = string
  default     = "t3.micro"
  
}

variable "public_key" {
  description = "The SSH id_rsa.pub key for your laptop to ssh the instance"
  type        = string
  
}

variable "subnet_ids" {
  description = "The subnets which EC2 instance use"
  type        = list(string)
  
}

variable "instance_count" {
  description = "The number of EC2 instances"
  type        = number
  default     = 1  
}

variable "iam_instance_profile_name" {
  description = "The role name for granting EC2 permissions, used by CloudWatch Agent"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "The security groups list"
  type        = list(string)
}
