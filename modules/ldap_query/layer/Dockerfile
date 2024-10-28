FROM amazonlinux@sha256:5bf4cf420ef7e50835911993c6a2ddb0e8f5101c0ef89ca20e9d02a03c8c3a8c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
