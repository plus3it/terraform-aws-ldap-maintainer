FROM amazonlinux@sha256:5cb6ab1a1a13f33425b6c660a45f06298e204a22df1f9eeefe69cda3735d9757

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
