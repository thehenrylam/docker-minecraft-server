#!/bin/bash

export TARGET

set -euo pipefail

microdnf install dnf -y

dnf install 'dnf-command(config-manager)' -y
dnf config-manager --set-enabled ol8_codeready_builder
tee /etc/yum.repos.d/ol8-epel.repo<<EOF
[ol8_developer_EPEL]
name= Oracle Linux \$releasever EPEL (\$basearch)
baseurl=https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF
dnf update -y

dnf install -y ImageMagick \
  file \
  sudo \
  net-tools \
  iputils \
  curl \
  git \
  jq \
  dos2unix \
  mysql \
  procps-ng \
  tzdata \
  rsync \
  nano \
  unzip \
  zstd \
  lbzip2 \
  libpcap \
  libwebp

bash /build/ol/install-gosu.sh

# Patched knockd
curl -fsSL -o /tmp/knock.tar.gz https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-$TARGET.tar.gz
tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz
ln -s /usr/local/sbin/knockd /usr/sbin/knockd
