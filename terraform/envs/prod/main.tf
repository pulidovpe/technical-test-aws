#
# Archivo: main.tf
# Entorno: prod
#

# --- Módulo de IAM y OIDC ---
module "iam" {
  source        = "../../modules/iam"
  aws_account_id= var.aws_account_id
  project_name  = var.project_name
  github_repo   = var.github_repo
}

# --- Módulo de Red y ALB (con ALB) ---
module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
  aws_region   = var.aws_region
  create_alb   = true
}

# --- Módulo de CloudWatch ---
module "cloudwatch" {
  source       = "../../modules/cloudwatch"
  project_name = var.project_name
}

# --- Módulo de ECS y Fargate ---
module "ecs" {
  source          = "../../modules/ecs"
  project_name    = var.project_name
  aws_region      = var.aws_region
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  alb_sg_id       = module.network.alb_sg_id
  react_tg_arn    = module.network.react_tg_arn
  api_tg_arn      = module.network.api_tg_arn
  app_sg_id       = module.network.app_sg_id
  api_log_group   = module.cloudwatch.api_log_group_name
  react_log_group = module.cloudwatch.react_log_group_name
}
