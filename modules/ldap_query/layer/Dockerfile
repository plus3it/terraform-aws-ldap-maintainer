FROM amazonlinux@sha256:ceeab7e010ed03ea155cfbbfd7140672eba5a49e1110b8b4ed35342312c3f21a

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
