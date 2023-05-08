provider "aws" {
    region = "us-east-1"
}

resource "aws_ecs_cluster" "fbooking-cluster" {
    name = var.fbooking-cluster-name
    capacity_providers = [aws_ecs_capacity_provider.test.name]
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
    name = "fbooking-cluster-capacity-provider"
    auto_scaling_group_provider {
        auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
        managed_termination_protection = "ENABLED"

        managed_scaling {
        status          = "ENABLED"
        target_capacity = 85
        }
    }
}

resource "aws_autoscaling_group" "asg" {
    name                      = "test-asg"
    launch_configuration      = aws_launch_configuration.lc.name
    min_size                  = 1
    max_size                  = 3
    desired_capacity          = 1
    health_check_type         = "ELB"
    health_check_grace_period = 300
    vpc_zone_identifier       = module.vpc.public_subnets

    target_group_arns     = [aws_lb_target_group.lb_target_group.arn]
    protect_from_scale_in = true
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "lc" {
    name          = "test_ecs_lc"
    image_id      = "ami-02396cdd13e9a1257"
    instance_type = "t2.micro"
    lifecycle {
        create_before_destroy = true
    }
    iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
    key_name                    = var.key_name
    security_groups             = [
        aws_security_group.ec2-sg.id,
        aws_security_group.rds.id
        ]
    associate_public_ip_address = true
    user_data                   = <<EOF
                                    #! /bin/bash
                                    sudo apt-get update
                                    sudo echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
                                    EOF
}























resource "aws_ecs_task_definition" "fbooking-task-definition" {
    family = var.task-definition-family
    network_mode = "awsvpc"
    cpu = 1024
    memory = 512
    runtime_platform {
        cpu_architecture = "X86_64"
        operating_system_family = "LINUX"
    }
    requires_compatibilities = ["EC2"]
    container_definitions = jsonencode([
        {
        name      = var.con
        image     = local.fbooking_backend_image
        cpu       = 1
        memory    = 512
        essential = true
        portMappings = [
            {
            containerPort = 8080
            hostPort      = 8080
            }
        ]
        environment = var.enviroment_container_definitions
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