output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id     # * will outputs all the subnets with list
}

output "public_subnets_map" {
  value = { for s in aws_subnet.public : s.tags.Name => s.id }
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_subnets_map" {
  value = { for s in aws_subnet.private : s.tags.Name => s.id }
}