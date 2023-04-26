terraform {
  backend "s3" {
    bucket = "f-booking-terraform-remote-state"
    key = "vpc-fb-state/terraform.tfstate"
    region = "us-east-1"
    
  }
}