FROM amazonlinux@sha256:3c663506cf84b035d68c6450c48f76092821736d6b0615d8bd45f3caf525abe7

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
