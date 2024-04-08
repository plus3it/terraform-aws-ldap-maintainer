FROM amazonlinux@sha256:ef9435f95b6fc5e7fd9ea156499e62a86f770d9928dfc83ecaa74af4fac3a663

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
