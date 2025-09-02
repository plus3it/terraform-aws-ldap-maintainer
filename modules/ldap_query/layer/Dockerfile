FROM amazonlinux@sha256:f5077958231a41decbd60c59c48cdb30519b77fdd326e829893470e3a8aa2e55

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
