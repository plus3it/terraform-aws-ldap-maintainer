FROM amazonlinux@sha256:1293fb4fa103ea81a8769d7b0aa000072884b0750c0a28563fd9838fea784245

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
