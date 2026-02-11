# DevSecOpsTest – CI/CD + IaC + Security Scans

Repositorio de ejemplo con:
- Infraestructura como código (Terraform sobre Azure).
- Construcción de imágenes Docker (API y Job).
- Escaneo de IaC (Checkov) y de contenedores (Trivy) con salida SARIF a GitHub Code Scanning.
- Despliegue automatizado por branch mediante GitHub Actions y autenticación OIDC (sin secretos largos).

## Requisitos

### Local
- Azure CLI (`az`)
- Terraform
- Docker (opcional si quieres construir imágenes localmente)

### En GitHub
Configurar **Secrets** y **Variables** en el repositorio (Settings → Secrets and variables → Actions).

## Variables (Actions → Variables)
- `TFSTATE_RG` = `rg-techflow-tfstate`
- `TFSTATE_STORAGE` = `sttechflowtfstate`
- `TFSTATE_CONTAINER` = `tfstate`
- `ACR_NAME` = `techflowdevacr`
- `AZURE_RESOURCE_GROUP` = `rg-techflow-dev`

## Secrets (Actions → Secrets)
- `AZURE_CLIENT_ID` = *(Client ID del App Registration con OIDC)*
- `AZURE_TENANT_ID` = `13d44989-0830-4867-9fd6-da7ae500a47f`
- `AZURE_SUBSCRIPTION_ID` = `bfd5c8d6-d16f-464b-99b0-1bf67d6ca929`
- `MY_SECRET_VALUE` = *(secreto requerido por Terraform)*

> Nota: `AZURE_CLIENT_ID` debe corresponder al App Registration que tenga Federated Credentials configurados para GitHub (`pull_request`, `develop`, `main`) y roles RBAC sobre el Storage del tfstate, el RG del ambiente y el ACR.

## Estructura del proyecto

- `infra/` Terraform (env y módulos)
- `app/` API (Dockerfile + código)
- `job/` Job (Dockerfile + script)
- `.github/workflows/` Pipelines CI/CD

## Ejecución local

### 1) Autenticación Azure
```bash
az login
az account set --subscription bfd5c8d6-d16f-464b-99b0-1bf67d6ca929
