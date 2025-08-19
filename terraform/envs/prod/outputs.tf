#
# Archivo: outputs.tf
# Salidas del entorno de producción.
#

output "alb_dns_name" {
  description = "El nombre DNS del Load Balancer de producción."
  value       = module.network.alb_dns_name
}
