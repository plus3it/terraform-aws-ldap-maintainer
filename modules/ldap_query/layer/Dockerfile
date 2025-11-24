FROM amazonlinux@sha256:99c2f938acd0d2a154a005b8dd30c90718727736c60cc93e718f68020948a41d

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
