FROM amazonlinux@sha256:8c22ec81612b78284b5db864e0fad3c8df7688a8fd5baa861d69fe3baf2c7377

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
