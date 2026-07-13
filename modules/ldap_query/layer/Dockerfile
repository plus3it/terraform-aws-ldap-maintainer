FROM amazonlinux@sha256:f590f33787c76bee9c42cc6826ee887bc1f3b60ba5ed137af450a6c0a79cdb57

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
