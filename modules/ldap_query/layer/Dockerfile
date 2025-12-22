FROM amazonlinux@sha256:57f00a32ff213e126c59e03f8a7ecb662b1887c1ef31c709865e6fd5c72cac07

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
