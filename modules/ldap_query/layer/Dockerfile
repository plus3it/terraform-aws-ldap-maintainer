FROM amazonlinux@sha256:e62b7b67cc1321b3a36930f30d915cf93f725fa47043a27e7956c52e3f4038b1

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
