#!/bin/bash

# Terraform init/plan/apply
terraform init
terraform plan
terraform apply

# Cool down for AWS provisioning of EKS resources then re-run for config map application
sleep 30
terraform plan
terraform apply

# kubectl <--> eks config update
aws eks --region eu-north-1 update-kubeconfig --name eks-nodzu-cluster-1

# Generate Github webhook secret
export WEBHOOK_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Populate Atlantis helm values and install
envsubst < src/atlantis-values.yaml.template > src/atlantis-values.yaml
helm install atlantis stable/atlantis -f src/atlantis-values.yaml

# Retrieve ELB domain name with cool down for AWS provisioning
sleep 30
export ATLANTIS_URL=$(kubectl describe service atlantis | grep LoadBalancer\ Ingress | sed -e 's/.*://' | tr -d '[:blank:]')

# Populate JSON payloads for deploying Github <--> Atlantis webhook and pull request
envsubst < src/github-webhook.json.template > src/github-webhook.json
envsubst < src/github-pull-request.json.template > src/github-pull-request.json

# Deploy Github webhook
curl --user "${GITHUB_USER}:${GITHUB_TOKEN}" -X POST -H "Content-Type: application/json" -d @src/github-webhook.json ${GITHUB_API_URL}/hooks

# Create Github pull request to test webhook
curl --user "${GITHUB_USER}:${GITHUB_TOKEN}" -X POST -H "Content-Type: application/json" -d @src/github-pull-request.json ${GITHUB_API_URL}/pulls
