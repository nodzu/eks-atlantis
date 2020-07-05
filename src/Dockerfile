FROM alpine:3.12

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
    bash \
    curl \
    gettext \
    openssl \
    py3-pip

ARG TERRAFORM_VER=0.12.28
ARG KUBECTL_VER=1.18.5
ARG ARCH=amd64

RUN pip3 --no-cache-dir install --upgrade \
    awscli

RUN curl -o /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_${ARCH}.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin/ && \
    chmod 0700 /usr/local/bin/terraform && \
    rm /tmp/terraform.zip

RUN curl -o /usr/local/bin/kubectl \
    #https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/${ARCH}/kubectl && \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/${ARCH}/kubectl && \
    chmod 0700 /usr/local/bin/kubectl

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && \
    chmod 0700 get_helm.sh && \
    bash get_helm.sh && \
    rm get_helm.sh

WORKDIR /mnt

CMD ["/bin/bash"]
