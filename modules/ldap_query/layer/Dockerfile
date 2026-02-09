FROM amazonlinux@sha256:2f10659a297494a1842d8b122027e3d865a7d4e5a88c056e53f45316ffc9c985

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
