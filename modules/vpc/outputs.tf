output "aws_public_ip1" {
  value = aws_eip.eip[*].public_ip
}
