# Technical Test AWS
Prueba técnica usando git para clonar un repo y terraform para desplegarlo en una cuenta aws.

## 🚀 Tecnologías Requeridas

- Git
- Docker
- Docker Compose
- Terraform
- OpenID
- AWS CLI

## 🛠️ Instalación

1. Crear un par de repositorios públicos ECR en una cuenta de AWS.
   Se sugieren:
   - test_app_container
   - test_api_container
2. Clonar el repositorio con el código fuente de la aplicación:
   ```
   git clone https://github.com/homecu/BlossomAwsDeploymentTest.git
   ```
3. Logearse en el repositorio ECR con docker y entrar al repositorio para construir las imágenes docker y subirlas el ECR:
   ```
   aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/xxxxxxx
   cd BlossomAwsDeploymentTest
   cd test-app
   docker build --platform linux/amd64 --push -t public.ecr.aws/xxxxxxx/test_app_container:latest .
   cd ..
   cd test-api
   docker build --platform linux/amd64 --push -t public.ecr.aws/xxxxxxx/test_api_container:latest .
   ```
4. Sino se posee el código terraform, descargar el siguiente repositorio.
   ```
   git clone https://github.com/pulidovpe/technical-test-aws.git
   ```
5. Ubicarse en la carpeta del proyecto de terraform:
   ```
   cd technical-test-aws/terraform/envs/dev
   ```
6. Configurar variables en el archivo `terraform.tfvars`.
   ```
   project_name   = "technical-test-aws"
   aws_region     = "us-east-1"
   ami_id         = "ami-00ca32bbc84273381"
   github_repo    = "pulidovpe/technical-test-aws"
   ecr_registry   = "public.ecr.aws/xxxxxxx"
   react_repo     = "test_app_container"
   api_repo       = "test_api_container"
   aws_account_id = "11111111111"
   ```   
7. Backend local:
   Si se va a realizar un despliegue local, se debe eliminar el archivo backend.tfvars y eliminar o comentar la linea 14 del archivo providers.tf en el entorno a usar.
   ```
   ## backend "s3" {}
   ```
8. Inicializar terraform:
   ```
   terraform init
   ```
9. Ejecutar el plan y luego aplicar:
   ```
   terraform plan -var-file="terraform.tfvars"

   terraform apply -var-file="terraform.tfvars"
   ```

Nota: 
- Debe tener configuradas las credenciales del AWS CLI.
- Terraform creará un proveedor de identidad basado en OpenID y un rol de IAM con los permisos necesarios para poder desplegar los recursos.
- Si usa el entorno *dev*, terraform creará una vpc con una subnet, un grupo de seguridad, un IGW, una tabla de rutas, un par de registros en cloudwatch y una instancia EC2.
- Si se cambia directorio *terraform/envs/prod* se ejecutará el entorno *prod* el cual creara una configuración más compleja en un cluster ECS con un balanceador de carga y auto escalado.

### Mejoras para el entorno de producción:

- Actualizar el módulo *network* para que éste cree subnets públicas y privadas.
- Se puede implementar la creación de una instancia RDS con postgres en lugar de desplegar la BD en un contenedor.

NOTA: La aplicación clonada del repositorio facilitado tiene la URL de acceso *quemada* en el código fuente como localhost. Por lo tanto se necesitan hacer cambios para que la aplicación del contenedor pueda realizar actualizaciones correctamente en la Base de datos.

### Variables de Entorno en caso de usar Github Actions

| NOMBRE | VALOR |
| - | - |
| `AWS_REGION` | `us-east-1` |
| `BUCKET_NAME` | `xxx-backend-tfstate` |
| `ECR_REPO_1` | `test_app_container` |
| `ECR_REPO_2` | `test_api_container` |
| `ECR_REPO_NAME` | `public.ecr.aws/xxxxxxx` |
| `PROJECT` | `BlossomAwsDeploymentTest` |
| `REPO` | `technical-test-aws` |