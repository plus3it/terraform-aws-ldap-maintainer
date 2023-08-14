FROM amazonlinux@sha256:2abc7d4cf0938b9c6cc72de4b477576b40c7577e882dce9a26d7639ab79f9703

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
