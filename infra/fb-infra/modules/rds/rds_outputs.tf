output "rds-sg" {
    value = aws_security_group.rds
}
output "ec2-sg" {
    value = aws_security_group.ec2
}

output "db_instance_address" {
    value = module.db.db_instance_address
}
output "db_instance_port" {
    value = module.db.db_instance_port
}

output "db_instance_username" {
    value = module.db.db_instance_username
    sensitive = true
}
output "db_instance_password" {
    value = module.db.db_instance_password
    sensitive = true
}

output "db_instance_name" {
    value = module.db.db_instance_name
    sensitive = true
}