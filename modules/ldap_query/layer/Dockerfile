FROM amazonlinux@sha256:ad882807c6c88f478186fa2632637380e06071a303e2b3bd96ab71846a77c6a3

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
