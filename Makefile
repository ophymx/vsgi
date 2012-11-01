NAME := VSGI
PKGS := --pkg gee-1.0 --pkg gio-2.0 --pkg posix --pkg libfcgi

include common.mk

run: build/simple-server
	build/simple-server

