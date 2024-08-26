FROM amazonlinux@sha256:171fe68a5c4114e48c19513c6341da2c6d693454f62edddaf7ac0ad2f13693d0

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
