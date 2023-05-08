resource "aws_security_group" "rds" {
    name_prefix = "rds-sg"
    description = "Security group for RDS"
    vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

    ingress {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        security_groups = [aws_security_group.ec2.id]
    }

    tags = {
        Environment = "dev"
    }
    }

    resource "aws_security_group" "ec2" {
    name_prefix = "ec2-sg"
    description = "Security group for EC2"
    vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

    tags = {
        Environment = "dev"
    }
}