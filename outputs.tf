output "vpc_info" {
  description = "The architecture of VPC information"
  value = {
    vpc_id     = module.vpc.vpc_id
    cidr       = module.vpc.vpc_cidr

  }
  
}

# the map of subnets details
output "Network_map" {
  description = "The table of ALL the subnets ID and Name"
  value = {
    public_subnets    = module.vpc.public_subnets_map
    private_subnets   = module.vpc.private_subnets_map
  }
  
}

# count the subnets
output "subnet_count" {
  description = "count the number of private subnets and public subnets"
  value = {
    public_subnets_count  = length(module.vpc.public_subnet_ids)
    private_subnets_count = length(module.vpc.private_subnet_ids)
  }  
}

# output the security group info
output "security_group_id" {
  value = module.sg.sg_id
}

output "web_server_ips" {
  value = module.ec2.public_ips
}

# output the ssh command when you need to connect to the server 
output "ssh_commands" {
  description = "快速 SSH 连接命令"
  value = [
    for ip in module.ec2.public_ips : 
    "ssh -i ~/.ssh/id_rsa ubuntu@${ip}"
  ]
}