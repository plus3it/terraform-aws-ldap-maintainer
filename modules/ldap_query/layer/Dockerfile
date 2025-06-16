FROM amazonlinux@sha256:54064c8f8487b81679fa8b8ddfc75a8eff98d85bdd07b6b2ce9ed7cc18754fb2

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
