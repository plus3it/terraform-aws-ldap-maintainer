FROM amazonlinux@sha256:1df62ceb869d3c8eef4dc48f944de3a27cbddcb16887c653281bd525d5ae6590

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
