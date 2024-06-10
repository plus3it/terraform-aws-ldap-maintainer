FROM amazonlinux@sha256:0d172f83b07323d8a8a08ea2242b7d64eb676f013eba269a158f229ce062a24f

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
