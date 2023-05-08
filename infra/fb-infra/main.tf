provider "aws" {
    region = var.aws_region
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "flight-booking-vpc"
    
    cidr = var.cidr
    azs             = var.azs
    private_subnets = var.private_subnets
    public_subnets  = var.public_subnets

    enable_nat_gateway = false
    enable_vpn_gateway = false

    tags = {
        Terraform = "true"
        Environment = "dev"
    }
    public_subnet_tags = {
        name = "fb_public_subnet"
        }
    private_subnet_tags ={
        name = "fb_private_subnet"
        }
    igw_tags = {
        name = "igw-flight-booking"
    }
}

module "db" {
    source  = "terraform-aws-modules/rds/aws"

    identifier = "fb-database"

    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.t2.micro"
    allocated_storage = 5

    db_name  = var.db_name
    username = var.username
    port     = var.port

    iam_database_authentication_enabled = true

    vpc_security_group_ids = module.vpc.default_security_group_id

    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"

    monitoring_interval = "0"

    tags = {
        Owner       = "user"
        Environment = "dev"
    }

    # DB subnet group
    create_db_subnet_group = true
    subnet_ids             = module.vpc.private_subnets
    availability_zone  = var.availability_zone

    # DB parameter group
    family = "mysql5.7"

    # DB option group
    major_engine_version = "5.7"

    # Database Deletion Protection
    deletion_protection = false

    parameters = [
        {
        name = "character_set_client"
        value = "utf8mb4"
        },
        {
        name = "character_set_server"
        value = "utf8mb4"
        }
    ]

    options = [
        {
        option_name = "MARIADB_AUDIT_PLUGIN"

        option_settings = [
            {
            name  = "SERVER_AUDIT_EVENTS"
            value = "CONNECT"
            },
            {
            name  = "SERVER_AUDIT_FILE_ROTATIONS"
            value = "37"
            },
        ]
        },
    ]
}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"

    repository_name = var.repository_name

    repository_read_write_access_arns = local.repository_read_write_access_arns
    repository_lifecycle_policy = jsonencode({
        rules = [
        {
            rulePriority = 1,
            description  = "Keep only 1 image",
            selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["v"],
            countType     = "imageCountMoreThan",
            countNumber   = 1
            },
            action = {
            type = "expire"
            }
        }
        ]
    })

    tags = {
        Terraform   = "true"
        Environment = "dev"
    }
}

module "ecs-cluster" {
    source = "./modules/ecs-cluster"

    fbooking-cluster-name = "fbooking-cluster"
    task-definition-family = "fbooking-task-definition"
    task-definition-cpu = 1024
    task-definition-memory = 512
    enviroment_container_definitions = [
            {
                name  = "FBOOKING_DB_NAME"
                value = "${local.FBOOKING_DB_NAME}"
            },
            {
                name  = "FBOOKING_DB_USER"
                value = "${local.FBOOKING_DB_USER}"
            },
            {
                name  = "FBOOKING_DB_PASSWORD"
                value = "${local.FBOOKING_DB_PASSWORD}"
            },
            {
                name  = "DB_INSTANCE_ADDRESS"
                value = "${local.DB_INSTANCE_ADDRESS}"
            },
            {
                name  = "DB_INSTANCE_PORT"
                value = "${local.DB_INSTANCE_PORT}"
            },
    ]
    container_definitions_image = module.ecr.repository_url
    container_definitions_name = "ec2-fbooking-backend"
}