FROM amazonlinux@sha256:c6f12c603e1abd267ca09c9c604a8b4eb421deddb83a90323cb835bdf8f1dce5

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
