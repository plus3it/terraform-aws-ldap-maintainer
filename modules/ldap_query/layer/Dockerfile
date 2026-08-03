FROM amazonlinux@sha256:c4b0d324eaacbc5805ab5f147ba71963184752da90340bf0803c1034a170c8d1

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
