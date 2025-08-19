#
# Módulo: ec2
# Archivo: main.tf
#
# Aprovisiona una instancia EC2, usando un grupo de seguridad
# provisto por el módulo de red.
#

resource "aws_instance" "dev_app" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  key_name      = "llave-test-aws"
  subnet_id     = var.public_subnets[0]
  vpc_security_group_ids = [
    var.app_sg_id,
  ]
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile_name

  # Script para autenticarse en ECR y ejecutar los contenedores
  user_data = <<-EOT
    #!/bin/bash
    # Este script se ejecuta al iniciar la instancia EC2.

    echo "Actualizando los paquetes del sistema..."
    sudo yum update -y

    echo "Instalando Docker..."
    sudo amazon-linux-extras install docker -y

    echo "Iniciando el servicio de Docker..."
    sudo service docker start

    # Agregando el usuario ec2-user al grupo de Docker para evitar usar 'sudo'
    sudo usermod -a -G docker ec2-user

    # Instalando la dependencia libxcrypt-compat
    echo "Instalando la dependencia libxcrypt-compat..."
    sudo yum install -y libxcrypt-compat

    # Instalando Docker Compose
    echo "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Reinicia la terminal para que los cambios del grupo de Docker tengan efecto
    newgrp docker

    # Autenticando con Amazon ECR
    echo "Autenticando con Amazon ECR..."
    aws ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${var.ecr_registry}

    # Creando el archivo docker-compose.yml
    echo "Creando el archivo docker-compose.yml..."
    cat <<EOF > docker-compose.yml
version: "3.7"
services:
  test_postgress_container:
    image: postgres
    container_name: testPostgresSQLContainer
    ports:
      - "5555:5432"
    environment:
      POSTGRES_PASSWORD: mypassword
      POSTGRES_USER: myusername
      POSTGRES_DB: test-local
    networks:
      test-network:
        ipv4_address: 172.20.0.2
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myusername -d test-local"]
      interval: 7s
      timeout: 5s
      retries: 5
    volumes:
      - test_postgress_volume:/var/lib/postgresql/data

  test_api_container:
    image: ${var.ecr_registry}/${var.api_repo}:latest
    container_name: testNodeContainer
    ports:
      - '4000:4000'
    networks:
      test-network:
        ipv4_address: 172.20.0.3
    depends_on:
      test_postgress_container:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:4000"]
      interval: 15s
      timeout: 5s
      retries: 3

  test_app_container:
    image: ${var.ecr_registry}/${var.react_repo}:latest
    container_name: testReactContainer
    ports:
      - '3000:3000'
    networks:
      test-network:
        ipv4_address: 172.20.0.4
    depends_on:
      test_api_container:
        condition: service_healthy

networks:
  test-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1

volumes:
  test_postgress_volume:

EOF

    echo "Levantando los servicios con Docker Compose..."
    docker-compose up -d

    echo "Proceso de user_data finalizado."
  EOT

  tags = {
    Name = "${var.project_name}-dev-ec2"
  }
}
