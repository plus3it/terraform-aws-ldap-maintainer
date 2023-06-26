FROM amazonlinux@sha256:28004508959f548dd98278f746c577a41b8340dc295e51d309e721e4e217bb85

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
