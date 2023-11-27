FROM amazonlinux@sha256:521e488723a1ae16055067e3b78954870cf1c08c9d45421b9f8ffad82b349e1c

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
