output "private_subnet_1" {
  value = aws_subnet.privateSN1.id
}

output "private_subnet_2" {
  value = aws_subnet.privateSN2.id
}

output "public_subnet_1" {
  value = aws_subnet.publicSN1.id
}

output "public_subnet_2" {
  value = aws_subnet.publicSN2.id
}

output "vpc_id" {
  value = aws_vpc.pocvpc.id
}
