FROM amazonlinux@sha256:472957840eacc161151bea727e9b7db4ca0c4fc857e870a9218e97f5c46b34e6

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
