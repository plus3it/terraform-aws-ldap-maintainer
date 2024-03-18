FROM amazonlinux@sha256:860843fc1dcf21cb06ce7a5cd0a6da92e9cb76bb8e0d1517fd93b6b8e2fa31bc

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
