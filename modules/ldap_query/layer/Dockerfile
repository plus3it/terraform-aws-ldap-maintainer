FROM amazonlinux@sha256:d96fde261b48b15e22c28c2eb54d087d39bcc19af7963d86539f18eea16b283c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
