FROM amazonlinux@sha256:04ff8139d7f2d9f026a5593f47e494ebe9f9819349f1b1ccc3be2bbbcdc317bf

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
