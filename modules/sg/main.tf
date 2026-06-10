# create security group
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP Network traffic"
  vpc_id      = var.vpc_id

  # allow SSH
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # allow HTTP
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # add outbound rule
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"      # -1 means all the protocols
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
}

