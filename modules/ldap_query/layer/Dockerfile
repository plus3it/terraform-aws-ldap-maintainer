FROM amazonlinux@sha256:7edb8e2f8b0a114acabae813a54144187343bf59e41bbd3e79a2cf187ca02c3d

RUN yum install -y \
  zip \
  python3 \
  python-devel \
  python3-devel \
  openldap-devel \
  gcc \
  && yum clean all

WORKDIR /var/task
