#
# Archivo: outputs.tf
#
# Exporta valores del módulo de ECS.
#

output "ecs_cluster_name" {
  description = "El nombre del clúster de ECS."
  value       = aws_ecs_cluster.app_cluster.name
}

output "react_service_name" {
  description = "Nombre del servicio de ECS de la aplicación React."
  value       = aws_ecs_service.react_service.name
}

output "api_service_name" {
  description = "Nombre del servicio de ECS de la API."
  value       = aws_ecs_service.api_service.name
}

output "react_task_definition_arn" {
  description = "ARN de la definición de tarea de React."
  value       = aws_ecs_task_definition.react_task.arn
}

output "api_task_definition_arn" {
  description = "ARN de la definición de tarea de la API."
  value       = aws_ecs_task_definition.api_task.arn
}
