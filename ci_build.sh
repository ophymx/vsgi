#!/bin/bash

set -e

export PATH="$(pwd)/bats/bin:$PATH"

make
make test
