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

1. Clonar el repositorio:
   ```
   git clone https://github.com/pulidovpe/technical-test-aws.git
   ```
2. Ubicarse en la carpeta del entorno:
   ```
   cd technical-test-aws/terraform/envs/dev
   ```
3. Configurar variables en el archivo `terraform.tfvars`.
   Nota: El registro ECR y los repositorios react_repo y api_repo deben existir en la cuenta AWS.
   ```
   project_name   = "technical-test-aws"
   aws_region     = "us-east-1"
   ami_id         = "ami-00ca32bbc84273381"
   github_repo    = "pulidovpe/technical-test-aws"
   ecr_registry   = "public.ecr.aws/12345678"
   react_repo     = "test_app_container"
   api_repo       = "test_api_container"
   aws_account_id = "1234567890"
   ```   
4. Backend local:
   Si se va a realizar un despliegue local, se debe eliminar el archivo backend.tfvars y eliminar o comentar la linea 14 del archivo providers.tf en el entorno a usar.
   ```
   ## backend "s3" {}
   ```
5. Inicializar terraform:
   ```
   terraform init
   ```
6. Ejecutar el plan y luego aplicar:
   ```
   terraform plan -var-file="terraform.tfvars"

   terraform apply -var-file="terraform.tfvars"
   ```
Nota: 
- Debe tener configuradas las credenciales del AWS CLI.
- Terraform creará un proveedor de identidad basado en OpenID y un rol de IAM con los permisos necesarios para poder desplegar los recursos.
- Si usa el entorno *dev*, terraform creará una vpc con una subnet, un grupo de seguridad, un IGW, una tabla de rutas, un par de registros en cloudwatch y una instancia EC2.
- Si se cambia directorio *terraform/envs/prod* se ejecutará el entorno *prod* el cual creara una configuración más compleja en un cluster ECS con un balanceador de carga y auto escalado.

### Variables de Entorno para Github

| NOMBRE | VALOR |
| - | - |
| `AWS_REGION` | `us-east-1` |
| `BUCKET_NAME` | `xxx-backend-tfstate` |
| `ECR_REPO_1` | `test_app_container` |
| `ECR_REPO_2` | `test_api_container` |
| `ECR_REPO_NAME` | `public.ecr.aws/12345678` |
| `PROJECT` | `BlossomAwsDeploymentTest` |
| `REPO` | `technical-test-aws` |


### Mejoras para el entorno de producción:

- Actualizar el módulo *network* para que éste cree subnets públicas y privadas.
- Se puede implementar la creación de una instancia RDS con postgres en lugar de desplegar la BD en un contenedor.

NOTA: La aplicación clonada del repositorio facilitado tiene la URL de acceso `quemada` en el código fuente como localhost. Por lo tanto se necesitan hacer cambios para que la aplicación del contenedor pueda realizar actualizaciones correctamente en la Base de datos.
