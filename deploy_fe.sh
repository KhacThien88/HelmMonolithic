#!/bin/bash
NAMESPACE="todoapp-test"
IMAGE_TAG="latest"
DOMAIN_SUFFIX="khacthienit.click"
SERVICES=("frontend-server")
for SERVICE_NAME in "${SERVICES[@]}"; do
  echo ">>> Bắt đầu deploy: $SERVICE_NAME"
  helm dependency build HelmMonolithic/charts/${SERVICE_NAME}
  helm upgrade --install ${SERVICE_NAME} HelmMonolithic/charts/${SERVICE_NAME} \
    --namespace ${NAMESPACE} --create-namespace \
    -f HelmMonolithic/charts/${SERVICE_NAME}/values.yaml \
    --set image.tag=${IMAGE_TAG} \
    --set ingress.domainName=${SERVICE_NAME}.${DOMAIN_SUFFIX}
done

kubectl apply -f HelmMonolithic/argocd/app_project/app_argofe_dev.yml
kubectl apply -f HelmMonolithic/argocd/app_project/app_argofe_staging.yml
kubectl apply -f HelmMonolithic/argocd/dev/frontend-server.yml
kubectl apply -f HelmMonolithic/argocd/staging/frontend-server.yml