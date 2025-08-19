#
# Archivo: variables.tf
# Variables del módulo EC2.
#

variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC."
  type        = string
}

variable "public_subnets" {
  description = "Lista de ID de las subredes públicas."
  type        = list(string)
}

variable "ami_id" {
  description = "ID de la AMI para la instancia EC2."
  type        = string
}

variable "app_sg_id" {
  description = "ID del Security Group para la aplicación EC2."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Nombre del perfil de instancia de IAM para la instancia EC2."
  type        = string
}

variable "aws_region" {
  description = "Región de AWS para el despliegue."
  type        = string
}

variable "ecr_registry" {
  description = "URL del registro de ECR."
  type        = string
}

variable "react_repo" {
  description = "Nombre del repositorio de React."
  type        = string
}

variable "api_repo" {
  description = "Nombre del repositorio de la API."
  type        = string
}
