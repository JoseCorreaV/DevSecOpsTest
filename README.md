# DevSecOpsTest – CI/CD + Terraform + Security Scans (Azure Container Apps)

Este repositorio implementa lo solicitado en la prueba:
- Infraestructura como código (Terraform) en Azure:
  - Key Vault (secreto de negocio)
  - Azure Container Registry (ACR)
  - Container Apps Environment (CAE)
  - Container App (API) con **init container** y lectura de secreto desde Key Vault via Managed Identity
  - Container App Job que imprime "Job ejecutado con éxito" y termina
- Pipeline CI/CD con GitHub Actions:
  - Build de imágenes Docker (API + Job)
  - Escaneo IaC (Checkov)
  - Escaneo de imágenes (Trivy)
  - Push a ACR y Deploy con Terraform en `develop` y `main`

## Requisitos

### Local
- Azure CLI (`az`)
- Terraform >= 1.5
- Docker (opcional si quieres build local)

### En GitHub (Settings → Secrets and variables → Actions)

#### Secrets
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `MY_SECRET_VALUE` (valor del secreto que se guarda en Key Vault)

#### Variables
- `ACR_NAME` = `techflowdevacr`
- `AZURE_RESOURCE_GROUP` = `rg-techflow-dev`
- `KEYVAULT_NAME` = `techflowdevkv`
- `TFSTATE_RG` = `rg-techflow-tfstate`
- `TFSTATE_STORAGE` = `sttechflowtfstate`
- `TFSTATE_CONTAINER` = `tfstate`

## Estructura del proyecto
- `infra/` Terraform (env y módulos)
- `app/` API Flask (retorna MY_SECRET)
- `job/` Job (imprime mensaje y termina)
- `.github/workflows/` Pipeline CI/CD

## Cómo ejecutar localmente (infra)

1) Login en Azure
```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
