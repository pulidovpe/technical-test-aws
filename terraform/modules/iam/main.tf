#
# Archivo main.tf
# Módulo: iam
#
# Aprovisiona el rol de IAM para GitHub Actions y un rol para las instancias
# EC2, con las políticas necesarias para la interacción con los servicios de AWS.
#

# --- Seccion 1: Rol para GitHub Actions y OIDC ---
# Permite a GitHub Actions asumir un rol de IAM.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# Politica de permisos para el rol de GitHub Actions
# Permite a GitHub Actions gestionar los recursos de infraestructura.
resource "aws_iam_policy" "github_oidc_policy" {
  name        = "GitHub-OIDC-Policy"
  description = "Permite a GitHub Actions gestionar recursos de AWS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:*",
          "iam:*",
          "ecs:*",
          "cloudwatch:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ssm:GetParameters"
        ],
        Resource = "*"
      },
    ]
  })
}

# Rol de IAM para GitHub Actions
resource "aws_iam_role" "github_oidc_role" {
  name               = "GitHub-OIDC-Role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.github_oidc_policy.arn
  ]
}

# --- Seccion 2: Rol y Perfil de Instancia para EC2 ---
# Rol de IAM para la instancia EC2.
resource "aws_iam_role" "instance_role" {
  name = "${var.project_name}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Politica que permitira a la instancia EC2 leer los repositorios de ECR.
# Esto le da los permisos necesarios para autenticarse y hacer el "pull".
resource "aws_iam_role_policy" "ecr_pull" {
  name = "${var.project_name}-ecr-pull-policy"
  role = aws_iam_role.instance_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

# Perfil de instancia que asocia el rol de IAM a la instancia EC2.
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.instance_role.name
}
