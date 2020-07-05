# nodzu

This is a short demo on using Terraform to provision an EKS cluster and using Helm to install the Atlantis application for managing Terraform. The Demo is orchestrated with a pre-built Docker image containing all the tools to complete the deployment. The source Dockerfile is located in the /src directory. All infrastructure management is handled by Terraform. The bash helper script
executed with the docker run command populates configs and payloads which are used to deploy Atlantis and test the Github integration. RBAC access is achieved by mapping IAM roles with a Kubernetes config map. 

### Requirements
- Admin level IAM account in AWS
- Configured awscli with standard ~/.aws/ config directory (this is mounted in the container for operations requiring AWS access)
- Docker
- Github personal access token

### Usage

The demo is executed by mounting the repository to /mnt inside the Docker container and running the `eks-atlantis-deploy.sh` script. All dependencies are contained within the Docker image, this repository, and as runtime environment variables. To deploy, issue the following command while in the base directory of the repository:

```
docker run  -v "$(pwd)":/mnt \
            -v ~/.aws:/root/ \
            -e GITHUB_USER=nodzu \
            -e GITHUB_TOKEN= \
            -e GITHUB_API_URL=https://api.github.com/repos/nodzu/eks-atlantis \
            -it armpits/eks-workstation:latest /bin/bash -c "./src/eks-atlantis-deploy.sh"
```

If all the necessary tools (Terraform, awscli, kubectl, Helm, envsubst, curl) are already on your workstation you can simply execute the bash script directly from your workstation. Pass in the environment variables listed above (-e flags) by your preferred method, and set your source directory as the base directory of this repository.  

The Docker image is a quick build, so if you want to avoid the Docker Hub hosted image just build from the provided src/Dockerfile and proceed using the docker run command above.  

### Deployment Steps

The actions being performed to complete the demo are:
1. Terraform init/plan/apply.
2. Awscli eks command to bring in config for kubectl (necessary for Kubernetes modules and Helm).
3. Re-run Terraform plan/apply (non-interactive) to apply Kubernetes config maps.
4. Generate webhook secret and populate Atlantis values.yaml.
5. Install Atlantis with Helm.
6. Retrieve load balancer domain name from Atlantis deployment and use this in populating JSON payload for creating the Github webhook (another cooldown happens first to allow the load balancer provisioning and DNS propagation to finish); post JSON to create repository webhook.
7. Populate JSON payload for creating Github pull request and post it to create pull request with existing feature branch. 

### Verification 

Inspect results on Atlantis and Github to confirm the deployment worked.

##### Atlantis 

To verify things are working on Atlantis' side check out the logs with kubectl. The same Docker image can be used as follows: 

```
docker run  -v "$(pwd)":/mnt \
            -v ~/.aws:/root/ \
            -it armpits/eks-workstation:latest /bin/bash -c "kubectl logs atlantis-0"
```  

The pull request creation from the initial deploy can be seen in Atlantis logs: 

```
2020/07/05 20:22:05+0000 [INFO] server: Identified event as type "opened"
2020/07/05 20:22:05+0000 [INFO] server: Executing autoplan
2020/07/05 20:22:05+0000 [INFO] server: POST /events – respond HTTP 200
...
2020/07/05 20:22:36+0000 [INFO] nodzu/eks-atlantis#5: Successfully ran "/usr/local/bin/terraform init -input=false -no-color -upgrade" in "/atlantis-data/repos/nodzu/eks-atlantis/5/default"
2020/07/05 20:22:37+0000 [INFO] nodzu/eks-atlantis#5: Successfully ran "/usr/local/bin/terraform workspace show" in "/atlantis-data/repos/nodzu/eks-atlantis/5/default"
2020/07/05 20:23:19+0000 [INFO] nodzu/eks-atlantis#5: Successfully ran "/usr/local/bin/terraform plan -input=false -refresh -no-color -out \"/atlantis-data/repos/nodzu/eks-atlantis/5/default/default.tfplan\"" in "/atlantis-data/repos/nodzu/eks-atlantis/5/default"
``` 

##### Github

If you have direct access to the repository the events associated with the webhook can simply be viewed in the web console under Settings > Webhooks. As a collaborator the Github API can be used to view events. Filtering the results down to the desired event is out of scope, but if you have just ran the demo the most recent events should show Atlantis activity. You can simply grep for "Plan" as this comes up in the body for Atlantis events:

(Enter the provided token at the password prompt)
```
curl --user "nodzu" https://api.github.com/repos/nodzu/eks-atlantis/events | grep Plan
```

Events such as the following show connectivity between Github and Atlantis: 

```
        "created_at": "2020-07-05T19:37:34Z",
        "updated_at": "2020-07-05T19:37:34Z",
        "author_association": "OWNER",
        "body": "Ran Plan for dir: `.` workspace: `default`
```

### Clean-up

Included is a simple clean-up script to make this process another docker run one-liner. Note that all helm associated resources need to be deleted first for a successful terraform destroy. The script handles this. 

```
docker run  -v "$(pwd)":/mnt \
            -v ~/.aws:/root/ \
            -it armpits/eks-workstation:latest /bin/bash -c "./clean-up.sh"
```
