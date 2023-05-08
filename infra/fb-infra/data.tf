data "terraform_remote_state" "fb-infra"{
    backend = "s3"

    config ={
        bucket = "f-booking-terraform-remote-state"
        key = "fb-state/terraform.tfstate"
        region = var.aws_region
    }
}