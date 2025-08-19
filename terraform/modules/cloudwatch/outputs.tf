#
# Archivo: outputs.tf
# Salidas del módulo de CloudWatch.
#
output "api_log_group_name" {
  description = "El nombre del grupo de logs para la API."
  value       = aws_cloudwatch_log_group.api_log_group.name
}

output "react_log_group_name" {
  description = "El nombre del grupo de logs para la aplicación de React."
  value       = aws_cloudwatch_log_group.react_log_group.name
}
