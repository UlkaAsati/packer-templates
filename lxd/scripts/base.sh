#!/usr/bin/env bash

set -o errexit
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

. /etc/lsb-release
sed -i "s#MIRROR#${MIRROR}#g" /etc/apt/sources.list
sed -i "s#DISTRIB_CODENAME#${DISTRIB_CODENAME}#g" /etc/apt/sources.list
dpkg --remove-architecture i386
apt-get update
apt-get install curl gnupg wget git software-properties-common python-jsonpatch -y --no-install-recommends
apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# install snaps
apt-get install snapd fuse -y

source /etc/os-release

# install travis user
userdel ubuntu
useradd -p travis -s /bin/bash -m travis -u 1000

echo travis:travis | chpasswd

# Save users having to create this directory at runtime (it's already on PATH)
mkdir -p /home/travis/bin

mkdir -p /opt
chmod 0755 /opt
chown -R travis:travis /home/travis /opt


# __setup_travis_user() {
#   if ! getent passwd travis &>/dev/null; then
#     if [[ -z "${TRAVIS_UID}" ]]; then
#       useradd -p travis -s /bin/bash -m travis -u 1000
#     else
#       useradd -p travis -s /bin/bash -m travis -u "${TRAVIS_UID}"
#       groupmod -g "${TRAVIS_UID}" travis
#       usermod -u "${TRAVIS_UID}" travis
#
#     fi
#   fi
#
#   echo travis:travis | chpasswd
#
#   # Save users having to create this directory at runtime (it's already on PATH)
#   mkdir -p /home/travis/bin
#
#   mkdir -p /opt
#   chmod 0755 /opt
#   chown -R travis:travis /home/travis /opt
# }
