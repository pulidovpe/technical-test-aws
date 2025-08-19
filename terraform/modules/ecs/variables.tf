#
# Archivo: variables.tf
# Variables del módulo IAM.
#

variable "project_name" {
  description = "Nombre del proyecto."
  type        = string
}

variable "aws_region" {
  description = "Región de AWS."
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

variable "alb_sg_id" {
  description = "ID del Security Group del ALB."
  type        = string
}

variable "react_tg_arn" {
  description = "ARN del Target Group de React."
  type        = string
}

variable "api_tg_arn" {
  description = "ARN del Target Group de la API."
  type        = string
}

variable "api_log_group" {
  description = "Nombre del log group de CloudWatch para la API."
  type        = string
}

variable "react_log_group" {
  description = "Nombre del log group de CloudWatch para React."
  type        = string
}

variable "app_sg_id" {
  description = "ID del Security Group para las tareas de ECS."
  type        = string
}
