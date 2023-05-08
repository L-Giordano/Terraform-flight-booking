variable "repository_read_write_access_arns" {}
variable "repository_name" {}

module "ecr" {
    source = "terraform-aws-modules/ecr/aws"

    repository_name = "fbooking-backend"

    repository_read_write_access_arns = "${var.repository_read_write_access_arns}"
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