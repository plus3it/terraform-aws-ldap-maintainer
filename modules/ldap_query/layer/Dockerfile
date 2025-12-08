FROM amazonlinux@sha256:d8566f52e9af381444249674c43132920e6b7f4e1355d771b317ca4ac4ccab93

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
