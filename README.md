# nodzu

This is a short demo on using Terraform to provision an EKS cluster and using Helm to install the Atlantis application for managing Terraform. The Demo is orchestrated with pre-built Docker i
mage containing all the tools to complete the deployment. The source Dockerfile is located in the src directory. All infrastructure management is handled by Terraform. The bash helper script
executed with the docker run command populates configs and payloads which are used to deploy Atlantis and test the Github integration. RBAC access is achieved by mapping IAM roles with a Kubernetes config map. 

### Requirements
- Admin level IAM account in AWS
- Configured awscli with standard ~/.aws/ config directory (this is mounted in the container for operations requiring AWS access)
- Docker
- Github personal access token

### Usage

The demo is executed by mounting the repository to /mnt inside the Docker container and running the `eks-atlantis-deploy.sh` script. All dependencies are contained within the Docker image, this repository, and as runtime environment variables. To deploy, issue the following command from your workstation:

```
docker run  -v "$(pwd)":/mnt \
            -v ~/.aws:/root/ \
            -e GITHUB_USER=nodzu \
            -e GITHUB_TOKEN= \
            -e GITHUB_API_URL=https://api.github.com/repos/nodzu/eks-atlantis \
            -e GIT_BRANCH=feature/service-accounts \
            -it armpits/eks-workstation:latest /bin/bash -c "./src/eks-atlantis-deploy.sh"
```

If all the necessary tools (Terraform, awscli, kubectl, Helm, envsubst, curl) are already on your workstation you can simply execute the bash script directly from your workstation. Pass in the environment variables listed above (-e flags) by your preferred method, and set your source directory as the base directory of this repository.  

The Docker image is a quick build, so if you want to avoid the Docker Hub hosted image just build from the provided src/Dockerfile and proceed using the docker run command above.  

### Deployment Steps

The actions being performed to complete the demo are:
1. Terraform init/plan/apply.
2. Cooldown for EKS api to become available then re-run Terraform to apply the Kubernetes config maps.
3. Awscli eks command to bring in config for kubectl (necessary for Helm).
4. Generate webhook secret and populate Atlantis values.yaml.
5. Helm installs Atlantis.
6. Retrieve load balancer domain name from Atlantis deployment and use this in populating JSON payload for creating Github webhook (another brief cooldown happens first to allow the load balancer provisioning to finish); post JSON to create repository webhook.
7. Populate JSON payload for creating Github pull request and post it to create pull request with existing feature branch.
