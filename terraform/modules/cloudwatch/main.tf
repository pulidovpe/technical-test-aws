#
# Módulo: cloudwatch
#
# Aprovisiona los grupos de logs para la aplicación de React y la API de Node.js.
#
resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "${var.project_name}-api-logs"
  retention_in_days = 7
  tags = {
    Name = "${var.project_name}-api-logs"
  }
}

resource "aws_cloudwatch_log_group" "react_log_group" {
  name              = "${var.project_name}-react-logs"
  retention_in_days = 7
  tags = {
    Name = "${var.project_name}-react-logs"
  }
}
