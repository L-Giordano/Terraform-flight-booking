
######General variables######

varible "aws_region" {
    type = string
    default = "us-east-1"
}
variable "backend_s3_bucket" {
    type = string
    default = "f-booking-terraform-remote-state"
}
variable "backend_s3_key" {
    type = string
    default = "fb-state/terraform.tfstate"
}

######VPC variables######

variable "cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "azs" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}
variable "private_subnets" {
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnets" {
    type = list(string)
    default = ["10.0.101.0/24", "10.0.102.0/24"]
}

######RDS variables######


variable "db_name" {
    type = string
    default = "fb"
}
variable "username" {
    type = string
    default = "user"
}
variable "port" {
    type = string
    default = "3306"
}
variable "availability_zone" {
    type = string
    default = "us-east-1a"
}


######ECR variables######


variable "repository_name" {
    type = string
    default = "fbooking-backend"
}

