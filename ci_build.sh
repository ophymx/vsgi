#!/bin/bash

set -e

export PATH="$(pwd)/bats/bin:$PATH"

#make
#make test

./waf configure
./waf
LD_LIBRARY_PATH="build:$LD_LIBRARY_PATH" ./build/libvsgi_TESTS
