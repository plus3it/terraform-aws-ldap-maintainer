FROM amazonlinux@sha256:32f61af6a24e178e8142fb7b0079f4af3a5cda6816cd53d2c611a921ef029ca0

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
