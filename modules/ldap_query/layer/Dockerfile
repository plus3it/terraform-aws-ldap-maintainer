FROM amazonlinux@sha256:0b311b67a640d7d18ceaa682029325314c04c397f3fe6ee7edcfdf0fbc1219cd

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
