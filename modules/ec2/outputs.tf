

output "public_ips" {
  description = "The Public IP address of EC2 instance"
  value       = aws_instance.ubuntu_web[*].public_ip
}


