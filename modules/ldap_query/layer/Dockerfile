FROM amazonlinux@sha256:fe46a60a46e7334e360e63125aea37b282f9992102e45b764459dc0a5ffcfafc

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
