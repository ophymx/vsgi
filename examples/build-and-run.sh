#!/bin/bash

set -e

. load.sh

./waf configure build test install --prefix install

pkg-config --cflags --libs vsgi-1.0

valac -o build/example_app \
      --vapidir install/share/vala/vapi \
      --pkg vsgi-1.0 \
      --pkg vsgi-server-simple-1.0 \
      examples/example_app.vala

./build/example_app
