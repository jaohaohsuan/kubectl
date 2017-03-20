FROM alpine:edge

RUN apk --update add curl bash

ARG kubernetesVer=1.5.4

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${kubernetesVer}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod 755 /usr/local/bin/kubectl
