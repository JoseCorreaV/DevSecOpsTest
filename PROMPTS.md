
## PROMPTS.md
```md
# PROMPTS.md – Uso de IA (asistencia puntual)

Este documento describe cómo se utilizó asistencia de IA de forma puntual para:
- Aclarar conceptos de configuración CI/CD y GitHub Actions.
- Corregir errores de configuración (por ejemplo: variables faltantes, rutas SARIF, autenticación OIDC en Azure).
- Proponer ajustes de comandos y snippets de configuración (YAML/Terraform) basados en mensajes de error observados.

## Áreas donde se usó asistencia

1. **Workflows GitHub Actions**
   - Ajustes de condiciones por branch (`pull_request` vs `push`).
   - Corrección de rutas de salida SARIF para evitar errores “Path does not exist”.
   - Separación de “evidencia” (reportes) vs “gating” (bloqueo del despliegue).

2. **Autenticación Azure con OIDC**
   - Interpretación de errores AADSTS y pasos para:
     - crear App Registration,
     - crear Service Principal,
     - crear Federated Identity Credentials (PR/develop/main),
     - asignar roles RBAC necesarios.

3. **Terraform backend (azurerm)**
   - Identificación de parámetros obligatorios del backend:
     - `resource_group_name`, `storage_account_name`, `container_name`, `key`,
     - y `use_azuread_auth=true` para autenticación.
   - Recomendación de uso de `-backend-config` para evitar prompts interactivos.

## Buenas prácticas aplicadas
- No se incluyeron secretos en el repositorio.
- Se priorizó OIDC (sin credenciales estáticas).
- Se mantuvo evidencia de seguridad en GitHub Code Scanning mediante SARIF.
- Se evitó automatizar “terraform import” en CI, ya que es una operación única que debe controlarse.
