# Keywords that imply a production environment
export SAFETY_PROD_KEYWORDS=("prod" "production" "live")

# Subcommands that are safe even on prod
export SAFETY_KUBECTL_SAFE_COMMANDS=("get" "describe" "config" "version" "cluster-info" "api-resources" "api-versions")

# Custom flag to skip confirmation prompt
export SAFETY_FORCE_FLAG="--safe-force"