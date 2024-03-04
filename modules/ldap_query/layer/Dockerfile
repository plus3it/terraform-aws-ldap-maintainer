FROM amazonlinux@sha256:db247dc601fcaa65b35d1074f4f34c8f31552ccd185a4002ffa152965e499c61

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
