FROM amazonlinux@sha256:5642f8e1796bb7e486021647c4914299c5b6c9102ee00cde8b47c962b1bf9e02

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
