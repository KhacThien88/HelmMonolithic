#!/bin/bash

SECRET_NAME="mysql-root-pass"
SOURCE_NAMESPACE="default"
TARGET_NAMESPACES=("todoapp-test" "todoapp-dev" "todoapp-staging")
echo ">>> Exporting secret [$SECRET_NAME] từ namespace [$SOURCE_NAMESPACE]..."
kubectl get secret "$SECRET_NAME" -n "$SOURCE_NAMESPACE" -o yaml > /tmp/$SECRET_NAME.yaml
sed -i '/creationTimestamp/d;/resourceVersion/d;/selfLink/d;/uid/d' /tmp/$SECRET_NAME.yaml

for ns in "${TARGET_NAMESPACES[@]}"; do
  echo ">>> Copy secret vào namespace: $ns"
  cp /tmp/$SECRET_NAME.yaml /tmp/$SECRET_NAME-$ns.yaml
  sed -i "s/namespace: $SOURCE_NAMESPACE/namespace: $ns/" /tmp/$SECRET_NAME-$ns.yaml
  kubectl apply -f /tmp/$SECRET_NAME-$ns.yaml
done