FROM amazonlinux@sha256:8ed3c0a996841537f75607e7d1de2114d8150391f75792e8da9268738547e73f

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
