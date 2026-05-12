FROM amazonlinux@sha256:c1872fb69ff9ed9581c999509dd0dcb4288235087f1df4999b866affdac0278d

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
