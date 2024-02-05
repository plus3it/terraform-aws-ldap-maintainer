FROM amazonlinux@sha256:d8323b3ea56d286d65f9a7469359bb29519c636d7d009671ac00b5c12ddbacf0

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
