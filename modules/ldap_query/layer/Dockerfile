FROM amazonlinux@sha256:048f244f2252ca4938521b79b89c34b6d710569fc00aa4ddda3828634b09bd73

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
