#
# Módulo: network
# Archivo: main.tf
#
# Aprovisiona la VPC, subredes, Internet Gateway, SG y,
# opcionalmente, un ALB.
#

# --- Seccion 1: Networking (VPC, Subnet, IGW, Route Table) ---

resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# --- Seccion 2: Seguridad (Security Groups) ---

# Grupo de Seguridad para el Balanceador de Carga (creación condicional)
resource "aws_security_group" "alb_sg" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.project_name}-alb-sg"
  description = "Permite trafico HTTP en el puerto 80 desde Internet."
  vpc_id      = aws_vpc.app_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Grupo de Seguridad de la Aplicacion (para ECS o EC2)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Permite trafico de la app desde el ALB (produccion) o Internet (dev)."
  vpc_id      = aws_vpc.app_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = var.create_alb ? aws_security_group.alb_sg[*].id : []
    cidr_blocks     = var.create_alb ? [] : ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Seccion 3: Load Balancer (ALB, creacion condicional) ---

resource "aws_lb" "alb" {
  count              = var.create_alb ? 1 : 0
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.alb_sg[*].id
  subnets            = [aws_subnet.public_subnet.id]
}

resource "aws_lb_target_group" "api_tg" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.project_name}-api-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "react_tg" {
  count       = var.create_alb ? 1 : 0
  name        = "${var.project_name}-react-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "http_listener" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react_tg[0].arn
  }
}
