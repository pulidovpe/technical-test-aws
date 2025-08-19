#
# Archivo: outputs.tf
# Salidas del entorno de desarrollo.
#
output "ec2_public_ip" {
  description = "La IP pública de la instancia EC2 de desarrollo."
  value       = module.ec2.public_ip
}
