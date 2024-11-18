FROM amazonlinux@sha256:6c2c3bb2ce484e8496c83bd672a62528406b96c74594b195f70dc3d7b420c296

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
