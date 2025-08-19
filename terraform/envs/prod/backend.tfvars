#
# Archivo: terraform/envs/dev/backend.tfvars
#

bucket         = "technical-test-aws-backend-tfstate"
key            = "prod/terraform.tfstate"
region         = "us-east-2"
encrypt        = true