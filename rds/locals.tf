locals {
vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.default_security_group_id,
    aws_security_group.rds.id]
}


