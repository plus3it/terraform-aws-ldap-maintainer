FROM amazonlinux@sha256:84acdf1bc33c2fa7d6f3b1c416f90836c2e37b3d18681b6db9f1b318afe71e63

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
