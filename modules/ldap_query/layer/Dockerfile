FROM amazonlinux@sha256:5fe11d17e56571a26e20df3fa1493bdf9139fb9f2cb6d84fad13104c7b869217

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
