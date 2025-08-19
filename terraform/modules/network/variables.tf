#
# Archivo: variables.tf
# Variables del módulo de red.
#

variable "project_name" {
  description = "Nombre del proyecto, usado para nombrar los recursos."
  type        = string
}

variable "aws_region" {
  description = "Región de AWS para el despliegue."
  type        = string
}

variable "create_alb" {
  description = "Establece si se debe crear un balanceador de carga. Si es falso, no se crean."
  type        = bool
  default     = true
}
