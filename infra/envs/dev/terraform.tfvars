resource_group_name = "rg-techflow-dev"
location            = "eastus"
prefix              = "techflowdev"

# NO lo subas con el secreto real. En local usa TF_VAR_my_secret_value
my_secret_value = "CAMBIAR_EN_LOCAL_O_GH_SECRETS"

app_image_tag = "1.0.0"
job_image_tag = "1.0.0"
