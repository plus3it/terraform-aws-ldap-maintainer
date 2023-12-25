FROM amazonlinux@sha256:355f1638075375e4db3a0f7aa9cd73f79fb1a738b72035bc66a3cfda30e0053b

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
