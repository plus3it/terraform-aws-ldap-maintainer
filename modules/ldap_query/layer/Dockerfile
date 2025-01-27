FROM amazonlinux@sha256:9b8a88839ab2c2abd6a8ded18e49255ab6cb89fcbb81eace8b330ee2afd598fd

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
