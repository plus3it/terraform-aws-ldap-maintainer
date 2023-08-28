FROM amazonlinux@sha256:bfb92230a15f2a03f318b078ed801953705f71897f3bc6a1bfaad21908ddbb3f

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
