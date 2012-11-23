#!/bin/sh
set -ex

type gnome-autogen.sh || {
  echo "You need to install gnome-common from the GNOME git"
  exit 1
}

mkdir -p m4

REQUIRED_AUTOMAKE_VERSION=1.11 \
REQUIRED_AUTOCONF_VERSION=2.64 \
REQUIRED_LIBTOOL_VERSION=2.2.6 \
REQUIRED_INTLTOOL_VERSION=0.40.0 \
bash gnome-autogen.sh --enable-vala \
                      --enable-valadoc \
                      --enable-strict-valac \
                      --enable-tests \
                      "$@"
