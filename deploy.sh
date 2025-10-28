#!/usr/bin/env bash
set -e

ACTION=${1:-apply}
LAYERS_APPLY=("network" "database" "app") # Apply in this order
LAYERS_DESTROY=("app" "database" "network") # Destroy in reverse order

if [ "$ACTION" == "destroy" ]; then
  LAYERS=("${LAYERS_DESTROY[@]}")
else
  LAYERS=("${LAYERS_APPLY[@]}")
fi

for LAYER in "${LAYERS[@]}"; do
  echo "🚀 Running $ACTION for layer: $LAYER"
  cd layers/$LAYER
  terraform init -upgrade
  terraform $ACTION -auto-approve -var-file=../../envs/prod.tfvars
  cd ../..
  echo "✅ $LAYER complete"
  echo "----------------------------------"
done
