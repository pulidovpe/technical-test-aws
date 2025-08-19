#
# Archivo: variables.tf
# Entorno: prod
#

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "ami_id" {
  description = "Id de la AMI"
  type        = string
}

variable "aws_account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "github_repo" {
  description = "El nombre del repositorio de GitHub"
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
