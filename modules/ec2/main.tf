# create SSH Key Pair
resource "aws_key_pair" "web_key" {
  key_name   = var.key_name
  public_key = var.public_key != null ? var.public_key : file("~/.ssh/id_rsa.pub")
}


resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
# create ec2 cloudwatch role enable cloudwatch monitoring
resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cw-role-${random_string.suffix.result}"

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
  user_data = <<-EOF
    #!/bin/bash
    set -e
    exec > /var/log/user-data.log 2>&1
    
    echo "Starting CloudWatch Agent installation at $(date)"
    
    # 下载并安装
    wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i -E amazon-cloudwatch-agent.deb
    rm amazon-cloudwatch-agent.deb
    
    # 创建配置
    mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CONFIG'
    {
      "metrics": {
        "metrics_collected": {
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CONFIG
    
    # 启动 agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -s \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    
    echo "CloudWatch Agent installation completed at $(date)"
  EOF


  user_data_replace_on_change = true

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


