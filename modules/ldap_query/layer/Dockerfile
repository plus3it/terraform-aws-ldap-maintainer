FROM amazonlinux@sha256:07900cb42ce7c5620507a79d02274d4257bc754a8359d1c7b4b52e61ffd14987

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
