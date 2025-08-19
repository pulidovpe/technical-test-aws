#
# Archivo: outputs.tf
# Salidas del módulo de EC2.
#

output "instance_id" {
  description = "ID de la instancia EC2."
  value       = aws_instance.dev_app.id
}

output "public_ip" {
  description = "IP pública de la instancia EC2."
  value       = aws_instance.dev_app.public_ip
}
