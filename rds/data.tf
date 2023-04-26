data "terraform_remote_state" "vpc"{
    backend = "s3"

    config ={
        bucket = "f-booking-terraform-remote-state"
        key = "vpc-fb-state/terraform.tfstate"
        region = "us-east-1"
    }
}
