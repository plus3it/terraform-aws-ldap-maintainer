FROM amazonlinux@sha256:d09f1353c3c0844852cff7bf103498a205532f5bca444e1ed6406e3c5402bb26

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
