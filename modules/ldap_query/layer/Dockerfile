FROM amazonlinux@sha256:8a147d2ace111975a5fa56bc873e2f55d4a78a661a9c47127cb8c2729937a7a8

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
