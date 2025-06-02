FROM amazonlinux@sha256:c3381e594bead0d6e859ae15b587854e3afc634e13a1ebdeef26a66ccdad46cd

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
