FROM amazonlinux@sha256:267b42d61c8eb5537270b62ec97b73bb104708d9245d343b5eeb1d92f0f65d3d

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
