terraform {
    backend "s3" {
        bucket = var.backend_s3_bucket
        key = var.backend_s3_key
        region = var.aws_region
    }
}