FROM amazonlinux@sha256:ba9b575c9c9df3b4b7be350adf5db26bd7cee4aa5e826c6b9d0f40a26d002435

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
