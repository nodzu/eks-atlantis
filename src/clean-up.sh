#!/bin/bash

# Uninstall all Helm deployments as associated resources interfere with Terraform destroy
helm ls --all --short | xargs helm delete

# Terraform destroy (interactive input)
terraform destroy
