locals {
    fbooking_backend_image = tostring(data.terraform_remote_state.ecr.outputs.ecr-repository_url)
    FBOOKING_DB_NAME = tostring(data.terraform_remote_state.rds.outputs.db_instance_name)
    FBOOKING_DB_USER = tostring(data.terraform_remote_state.rds.outputs.db_instance_username)
    FBOOKING_DB_PASSWORD = tostring(data.terraform_remote_state.rds.outputs.db_instance_password)
    DB_INSTANCE_ADDRESS = tostring(data.terraform_remote_state.rds.outputs.db_instance_address)
    DB_INSTANCE_PORT = tostring(data.terraform_remote_state.rds.outputs.db_instance_port)
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