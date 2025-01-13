FROM amazonlinux@sha256:6e7b74e958e8601f6e51cc59603544ea9946e69831525cb987c1a7ae3a7a1447

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
