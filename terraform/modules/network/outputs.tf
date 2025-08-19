#
# Archivo: outputs.tf
# Salidas del módulo de red.
#

output "vpc_id" {
  description = "El ID de la VPC."
  value       = aws_vpc.app_vpc.id
}

output "public_subnets" {
  description = "Una lista de los ID de las subredes públicas."
  value       = [aws_subnet.public_subnet.id]
}

output "alb_sg_id" {
  description = "ID del Security Group del ALB (solo si fue creado)."
  value       = var.create_alb ? aws_security_group.alb_sg[0].id : ""
}

output "app_sg_id" {
  description = "El ID del Security Group de la aplicación (para EC2 o ECS)."
  value       = aws_security_group.app_sg.id
}

output "alb_dns_name" {
  description = "El nombre DNS del Balanceador de Carga."
  value       = var.create_alb ? aws_lb.alb[0].dns_name : ""
}

output "react_tg_arn" {
  description = "El ARN del Target Group de React."
  value       = var.create_alb ? aws_lb_target_group.react_tg[0].arn : ""
}

output "api_tg_arn" {
  description = "El ARN del Target Group de la API."
  value       = var.create_alb ? aws_lb_target_group.api_tg[0].arn : ""
}
