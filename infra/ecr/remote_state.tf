terraform {
  backend "s3" {
    bucket = "f-booking-terraform-remote-state"
    key = "ecr-fb-state/terraform.tfstate"
    region = "us-east-1"
    
  }
}