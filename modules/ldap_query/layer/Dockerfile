FROM amazonlinux@sha256:162fc5b69e11e81023f83a1ab618b184927ff3002d0852432af3b6ae4a1b5304

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
