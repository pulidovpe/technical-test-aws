#
# Archivo: variables.tf
# Variables del módulo IAM.
#

variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
}

variable "github_repo" {
  description = "El nombre del repositorio de GitHub"
  type        = string
}

variable "aws_account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}
