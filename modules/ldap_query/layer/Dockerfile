FROM amazonlinux@sha256:03b398175f863675186c1a8b38f45d702c5ff0c0faa3a3de9089a0fc58ed7269

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
