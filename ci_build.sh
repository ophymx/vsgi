#!/bin/bash

set -e

./waf configure
./waf
./waf test
