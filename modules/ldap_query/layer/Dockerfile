FROM amazonlinux@sha256:ef1a9c856a0d3b2d581d0d9261540df3c6ab3a7f752546603c93f954def936a3

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
