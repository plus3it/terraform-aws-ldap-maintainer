FROM amazonlinux@sha256:1b091808a98a0a1b0570073421866f5a76adfa43e8d7a42b2f5dd0c60053a567

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
