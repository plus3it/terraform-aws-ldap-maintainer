FROM amazonlinux@sha256:5af63ef484a9613b3080bb3ae722b6e46b53714360290c5edba71f1af3ac733b

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
