FROM amazonlinux@sha256:97073cc66ae1fe66d59315987c36f4eeb98242a85086e972b4109bab4cb57454

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
