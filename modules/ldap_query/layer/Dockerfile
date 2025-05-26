FROM amazonlinux@sha256:a72ad02c10cc535f7b34da08c2a06b191a0c5824f1454531dd06db1236478102

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
