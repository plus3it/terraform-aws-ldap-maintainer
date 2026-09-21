FROM amazonlinux@sha256:74c545e3e04db388b00bd31d7cc5640d4e9c12058a6d72af938d113da3c82893

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
