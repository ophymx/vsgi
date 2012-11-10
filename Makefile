NAME := VSGI
PKGS := --pkg gee-1.0 --pkg gio-2.0 --pkg posix

FCGI_APP_FLAGS := --pkg libfcgi -X -lfcgi

include common.mk

run: build/simple-server
	build/simple-server

