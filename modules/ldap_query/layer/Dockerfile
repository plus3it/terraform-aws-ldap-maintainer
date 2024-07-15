FROM amazonlinux@sha256:d5b9690df4ce1a70d738d8c8f7a6b4275008df95d4ddc2435e4e8e4352db61a5

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
