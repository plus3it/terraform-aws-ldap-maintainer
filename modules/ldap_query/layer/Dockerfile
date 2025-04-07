FROM amazonlinux@sha256:fc7c82b2ba834045bdf454ef0f9e73d6fdf01166e08671037c8ffdaa9de2cac4

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
