FROM amazonlinux@sha256:ba5522360eea0f350e8f4444f0d49a4df0f824037144f7412193bd87dcd5e0fc

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
