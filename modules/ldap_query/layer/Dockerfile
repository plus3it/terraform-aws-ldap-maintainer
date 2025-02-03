FROM amazonlinux@sha256:8217eec04f21ec88f5fd0ce57641a9fa9a586af5c4d2a68c7fcd50f2146ddb03

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
