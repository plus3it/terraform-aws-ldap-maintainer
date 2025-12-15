FROM amazonlinux@sha256:383f900729263a3c63b8e7e3410f94282f02e246fa68bba066a61f82bece8330

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
