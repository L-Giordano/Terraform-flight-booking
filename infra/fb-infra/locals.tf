locals {
  repository_read_write_access_arns = data.terraform_remote_state.fb-infra.repository_read_write_access_arns.repository_read_write_access_arns
}
locals {
    FBOOKING_DB_NAME = module.db.db_instance_name
    FBOOKING_DB_USER = module.db.db_instance_username
    FBOOKING_DB_PASSWORD = module.db.db_instance_password
    DB_INSTANCE_ADDRESS = module.db.db_instance_address
    DB_INSTANCE_PORT = module.db.db_instance_port
}

locals {
    vpc_security_group_ids = [
        data.terraform_remote_state.vpc.outputs.default_security_group_id,
        data.terraform_remote_state.rds.outputs.ec2-sg.id,
        data.terraform_remote_state.rds.outputs.rds-sg.id
    ]
}

locals {
    subnet_id = data.terraform_remote_state.vpc.outputs.private_subnets[0]
}