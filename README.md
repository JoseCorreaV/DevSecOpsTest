# DevSecOpsTest – CI/CD + Terraform + Security Scans (Azure Container Apps)

Este repositorio implementa una solución DevSecOps completa en Azure utilizando:

- Terraform para Infraestructura como Código.
- Azure Container Apps para despliegue de API y Job.
- GitHub Actions para CI/CD.
- Escaneo automático de seguridad:
  - Checkov (Infraestructura)
  - Trivy (Imágenes Docker)

La solución soporta múltiples entornos (`dev` y `prod`) y despliega automáticamente según la rama.

---

# Arquitectura

Por cada entorno (`infra/envs/dev` y `infra/envs/prod`) se despliega:

- Azure Container Registry (ACR)
- Azure Container Apps Environment (CAE)
- Azure Key Vault (RBAC habilitado)
- User Assigned Managed Identity (UAMI)
- Azure Container App (API)
  - Usa Managed Identity
  - Lee secreto desde Key Vault
  - Incluye init container
- Azure Container App Job
  - Ejecuta tarea puntual
  - Lee secreto desde Key Vault

---

# Flujo de ramas

| Rama        | Qué hace |
|------------|----------|
| feature/*  | CI + Plan (sin deploy) |
| develop    | Deploy automático a DEV |
| main       | Deploy automático a PROD |

Flujo recomendado:


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
