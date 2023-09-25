FROM amazonlinux@sha256:c0910d0d46633cd66da065c5023014c8de735c3ea407129719ff0298273424bd

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
