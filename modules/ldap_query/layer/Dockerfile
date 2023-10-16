FROM amazonlinux@sha256:eb687b3a268c932c4f8cb4f79dadd97895fdcf12265708dfacd9d1a1e58644f3

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
