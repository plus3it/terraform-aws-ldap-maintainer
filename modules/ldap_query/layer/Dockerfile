FROM amazonlinux@sha256:b0016cbc423cd29bca07d5ff783c432c7f0477dc8d19bdf5828dd560a0b3d0b9

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
