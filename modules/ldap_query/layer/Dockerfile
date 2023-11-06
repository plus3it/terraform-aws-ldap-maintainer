FROM amazonlinux@sha256:6d13678b68a6db66e13f1c738a721e5df41e9911a89c47082584cc76599b1ce8

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
