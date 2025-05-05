FROM amazonlinux@sha256:cb5b4c509d62ae388f674c139ae5e8281fc160c217d474445e912043e1941988

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
