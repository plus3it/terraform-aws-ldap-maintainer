FROM amazonlinux@sha256:0aa4560b47da98d20a47b82c4185180dd7e76b7db5bdd145283d3fc7dfb52e9f

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
