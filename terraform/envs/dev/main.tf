#
# Archivo: main.tf
# Entorno: dev
#

# --- Módulo de IAM y OIDC ---
module "iam" {
  source        = "../../modules/iam"
  aws_account_id= var.aws_account_id
  project_name  = var.project_name
  github_repo   = var.github_repo
}

# --- Módulo de Red (sin ALB) ---
module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
  aws_region   = var.aws_region
  create_alb   = false
}

# --- Módulo de CloudWatch ---
module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  project_name = var.project_name
}

# --- Módulo de EC2 para el despliegue en dev ---
module "ec2" {
  source          = "../../modules/ec2"
  project_name    = var.project_name
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  ami_id          = var.ami_id
  app_sg_id       = module.network.app_sg_id

  iam_instance_profile_name = module.iam.instance_profile_name
  aws_region                = var.aws_region
  ecr_registry              = var.ecr_registry
  react_repo                = var.react_repo
  api_repo                  = var.api_repo
}
