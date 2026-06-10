# create SSH Key Pair
resource "aws_key_pair" "web_key" {
  key_name   = "ubuntu-web-key"
  public_key = var.public_key  
}


# create EC2 instance
resource "aws_instance" "ubuntu_web" {
  count          = var.instance_count
  ami            = var.ami_id
  instance_type  = var.instance_type

  subnet_id      = element(var.subnet_ids, count.index % length(var.subnet_ids))

  key_name       = aws_key_pair.web_key.key_name

  # associate the IAM role so that EC2 can send monitoring data to CloudWatch
  iam_instance_profile = var.iam_instance_profile_name

  # setup root block size
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  # assign security group
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = format("ubuntu-web-server-%02d", count.index + 1) # must occupy at least 2 characters in width
  } 

  # enable cloudwatch monitoring
  monitoring = true
  
}