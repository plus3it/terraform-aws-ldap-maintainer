FROM amazonlinux@sha256:97bee6ea9b724a96fc90f8a5a8738ec6d8a7c94a6b5a502dfed0461170b98137

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
