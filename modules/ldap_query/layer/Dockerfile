FROM amazonlinux@sha256:b0737d724480361f137d428136721fff45f56792d650f4675d1e5732bb1104e4

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
