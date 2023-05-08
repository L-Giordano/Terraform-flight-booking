provider "aws" {
    region = "us-east-1"
}

resource "aws_ecs_cluster" "fbooking-cluster" {
    name = "fbooking-cluster"
}

resource "aws_instance" "ec2_instance" {
    ami           = "ami-02396cdd13e9a1257"
    instance_type = "t2.micro"
    subnet_id     = local.subnet_id

    tags = {
        Name = "ec2-fbooking"
        ecs_cluster = "fbooking-cluster"
    }

    vpc_security_group_ids = local.vpc_security_group_ids

    user_data = <<-EOF
                #!/bin/bash
                echo ECS_CLUSTER=${aws_ecs_cluster.fbooking-cluster.name} >> /etc/ecs/ecs.config
                yum install -y ecs-init
                start ecs
                EOF
}

resource "aws_ecs_task_definition" "fbooking-task-definition" {
    family = var.task-definition-family
    network_mode = "awsvpc"
    cpu = var.task-definition-cpu
    memory = var.task-definition-memory
    runtime_platform {
        cpu_architecture = "X86_64"
        operating_system_family = "LINUX"
    }
    requires_compatibilities = ["EC2"]
    container_definitions = jsonencode([
        {
        name      = "ec2-fbooking-backend"
        image     = local.fbooking_backend_image
        cpu       = 1024
        memory    = 512
        essential = true
        portMappings = [
            {
            containerPort = 8080
            hostPort      = 8080
            }
        ]
        environment = [
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

        
        }
    ])
}



resource "aws_ecs_service" "fbooking-service" {
    name            = "fbooking-service"
    cluster         = aws_ecs_cluster.fbooking-cluster.id
    task_definition = aws_ecs_task_definition.fbooking-task-definition.arn
    desired_count   = 1
    launch_type     = "EC2"

    deployment_controller {
        type = "ECS"
    }
    
    network_configuration {
        security_groups = [
            data.terraform_remote_state.rds.outputs.rds-sg.id,
            data.terraform_remote_state.rds.outputs.ec2-sg.id,
            ]
        subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
        assign_public_ip = false
    }
}

output "ecs_service_name" {
    value = aws_ecs_service.fbooking-service.name
}

output "aws_ecs_cluster_name" {
    value = aws_ecs_cluster.fbooking-cluster.name
}

output "container_name" {
    value = jsondecode(aws_ecs_task_definition.fbooking-task-definition.container_definitions)[0].name
}

output "task-definition" {
    value = aws_ecs_task_definition.fbooking-task-definition.arn
}