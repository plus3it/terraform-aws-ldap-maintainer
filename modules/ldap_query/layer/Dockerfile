FROM amazonlinux@sha256:c4543691c8ce4157cbfe7d10170106eccb9dedd61f022980f062788d00e8af51

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
