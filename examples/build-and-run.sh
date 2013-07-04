#!/bin/bash

set -e

. load.sh

./waf configure build test install --prefix install

pkg-config --cflags --libs vsgi-1.0

valac -o build/setup_app.so \
      -X -fPIC -X -shared --library=setup_app \
      --vapidir install/share/vala/vapi \
      --pkg vsgi-1.0 examples/setup_app.vala

rm setup_app.vapi
cp build/setup_app.so install/lib/

./install/bin/vsgi-server-simple
