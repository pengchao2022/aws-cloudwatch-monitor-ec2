# create SSH Key Pair
resource "aws_key_pair" "web_key" {
  key_name   = var.key_name
  public_key = var.public_key != null ? var.public_key : file("~/.ssh/id_rsa.pub")
}

# create ec2 cloudwatch role enable cloudwatch monitoring
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# attched aws managed cloudwatch policy
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# create Instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-cloudwatch-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

# create EC2 instance
resource "aws_instance" "ubuntu_web" {
  count          = var.instance_count
  ami            = var.ami_id
  instance_type  = var.instance_type

  subnet_id      = element(var.subnet_ids, count.index % length(var.subnet_ids))

  key_name       = aws_key_pair.web_key.key_name

  # associate the IAM role so that EC2 can send monitoring data to CloudWatch
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # install cloudwatch agent on EC2
  user_data = file("${path.module}/install_cloudwatch.sh")

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


