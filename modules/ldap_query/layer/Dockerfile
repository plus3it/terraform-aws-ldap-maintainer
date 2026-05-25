FROM amazonlinux@sha256:f03d3254192161691b72be58219022adc2036bd0933aa2b6f3b744f20b2bbe8c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
