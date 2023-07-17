FROM amazonlinux@sha256:2a1003479903aeb2dc92e4735b2994e1b7b5cbaefd275c97f467f82a0eb82cef

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
