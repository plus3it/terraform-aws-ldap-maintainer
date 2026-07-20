FROM amazonlinux@sha256:0c74e9fbba754003cfa179fd5cc65be7790d7248443276948704b8a858b298e5

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
