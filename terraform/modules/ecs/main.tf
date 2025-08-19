#
# Módulo: ecs
#
# Aprovisiona el clúster de ECS, las tareas y los servicios con Auto Scaling.
#

# Rol de IAM para la ejecución de tareas Fargate.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cluster de ECS
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.project_name}-cluster"
}

# Definición de la tarea para la API de Node.js.
resource "aws_ecs_task_definition" "api_task" {
  family                   = "${var.project_name}-api-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "test-api-container"
      image     = "test_api_container:latest"
      essential = true
      portMappings = [
        {
          containerPort = 4000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.api_log_group
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Definición de la tarea para la aplicación de React.
resource "aws_ecs_task_definition" "react_task" {
  family                   = "${var.project_name}-react-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "test-react-container"
      image     = "test_app_container:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.react_log_group
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# Servicio de ECS para la API de Node.js.
resource "aws_ecs_service" "api_service" {
  name            = "${var.project_name}-api-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [var.alb_sg_id] # Usa el SG del módulo de red
    subnets         = var.public_subnets
  }
  load_balancer {
    target_group_arn = var.api_tg_arn
    container_name   = "test-api-container"
    container_port   = 4000
  }
}

# Servicio de ECS para la aplicación de React.
resource "aws_ecs_service" "react_service" {
  name            = "${var.project_name}-react-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.react_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [var.alb_sg_id] # Usa el SG del módulo de red
    subnets         = var.public_subnets
  }
  load_balancer {
    target_group_arn = var.react_tg_arn
    container_name   = "test-react-container"
    container_port   = 3000
  }
}

# Auto Scaling para el servicio de React
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.react_service.name}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
}

resource "aws_appautoscaling_policy" "ecs_scaling_policy" {
  name               = "${var.project_name}-ecs-scaling-policy"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
