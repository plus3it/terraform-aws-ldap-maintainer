FROM amazonlinux@sha256:d6b42a987b6699493e34cccb263fa5d6bb5a19308e781384c786a384a71bea04

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
