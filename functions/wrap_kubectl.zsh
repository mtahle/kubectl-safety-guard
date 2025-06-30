function is_prod_context() {
  local context="$1"
  for keyword in "${SAFETY_PROD_KEYWORDS[@]}"; do
    [[ "$context" == *"$keyword"* ]] && return 0
  done
  return 1
}

function is_safe_command() {
  local cmd="$1"
  for safe in "${SAFETY_KUBECTL_SAFE_COMMANDS[@]}"; do
    [[ "$cmd" == "$safe" ]] && return 0
  done
  return 1
}

function kubectl() {
  local args=("$@")
  local force_used=false
  local filtered_args=()

  # Extract force flag
  for arg in "${args[@]}"; do
    if [[ "$arg" == "$SAFETY_FORCE_FLAG" ]]; then
      force_used=true
    else
      filtered_args+=("$arg")
    fi
  done

  local base_cmd="${filtered_args[1]}"
  if is_safe_command "$base_cmd"; then
    command kubectl "${filtered_args[@]}"
    return $?
  fi

  local context="$(command kubectl config current-context 2>/dev/null)"
  if is_prod_context "$context"; then
    if [[ "$force_used" == false ]]; then
      echo "⚠️  You are about to run a command on a PRODUCTION cluster: [$context]"
      echo "Command: kubectl ${args[*]}"
      read "proceed?Are you sure? Type 'yes' to continue: "
      if [[ "$proceed" != "yes" ]]; then
        echo "❌ Aborted."
        return 1
      fi
    else
      echo "⚠️  Running in production context [$context] with $SAFETY_FORCE_FLAG"
    fi
  else
    echo "ℹ️  Running in non-prod context [$context]"
  fi

  command kubectl "${filtered_args[@]}"
}
