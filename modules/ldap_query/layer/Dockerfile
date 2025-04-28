FROM amazonlinux@sha256:51b2a6d2c7f920500b9a061b3f4776319ed40094ec4b75dcb2a4e3a1bdaed37a

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
