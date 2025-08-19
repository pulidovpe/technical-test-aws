
#
# Archivo: outputs.tf
# Salidas del módulo de IAM.
#

output "instance_profile_name" {
  description = "El nombre del perfil de instancia de IAM para las instancias EC2."
  value       = aws_iam_instance_profile.instance_profile.name
}

output "github_oidc_role_arn" {
  description = "El ARN del rol de IAM para GitHub Actions."
  value       = aws_iam_role.github_oidc_role.arn
}

