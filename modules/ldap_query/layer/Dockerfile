FROM amazonlinux@sha256:019cf20c5b98efcd548952d31df1768377916bf8d57d70d979c6c92bfd5e7446

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
