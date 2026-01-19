FROM amazonlinux@sha256:808df4d068adf02dadb815bdb32bd2b132ce70260571401adf3ff8a19e99ce82

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
