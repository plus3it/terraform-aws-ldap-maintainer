FROM amazonlinux@sha256:cfa6c2d0270c6517c0e46cb87aed7edcae8d9eb96af5f51814b6ee8680faaa2c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
