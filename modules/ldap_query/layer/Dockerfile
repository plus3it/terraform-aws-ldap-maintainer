FROM amazonlinux@sha256:3dfca23bb3b578c2807053e1a7b2db6a3622e9c147be79e5c2ea3a4569caafb3

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
