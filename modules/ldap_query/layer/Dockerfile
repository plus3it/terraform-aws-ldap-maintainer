FROM amazonlinux@sha256:eb5359d566df2b34cb58be63c2d0fa1476e7654833d4d3af307b930a8fac6446

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
