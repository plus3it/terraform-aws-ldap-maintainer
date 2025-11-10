FROM amazonlinux@sha256:5ea333708360add6cc16ecec2569b8b75b6ee862528217bac65ad80752f4129b

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
