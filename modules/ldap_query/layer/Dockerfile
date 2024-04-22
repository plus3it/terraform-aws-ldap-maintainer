FROM amazonlinux@sha256:5478f82c47e435ed988fa12a00b623ef3c920fadd669d40c596249cf81960c4c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
