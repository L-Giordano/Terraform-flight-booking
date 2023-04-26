output "rds-sg" {
    value = aws_security_group.rds
}
output "ec2-sg" {
    value = aws_security_group.ec2
}