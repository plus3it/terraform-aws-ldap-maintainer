FROM amazonlinux@sha256:5bf791027b4659e73c33a88a3fa2b314b8e2c0ee60cb1088a097171ee7f180db

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
