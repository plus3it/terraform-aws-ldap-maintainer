FROM amazonlinux@sha256:4f02d5d4500105878af64950f9c46cde3392b907907cb0d23a885c721a26f67d

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
