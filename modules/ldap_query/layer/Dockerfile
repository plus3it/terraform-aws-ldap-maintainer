FROM amazonlinux@sha256:0377b0a0f83dc67a044d179e0c4f069d2fbd3aeba43c545b61a26d5b6851b6d3

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
