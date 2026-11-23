FROM amazonlinux@sha256:9cf762f5099b606bcd851391317af7cd75b11363c4816ebcb5e91292dd5736a7

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
