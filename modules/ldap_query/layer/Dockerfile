FROM amazonlinux@sha256:c04a1012acc483977f61f7f91c28624a39a621e56a59781319a75dec528be9b6

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
