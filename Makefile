NAME := VSGI
PKGS := --pkg gee-1.0 --pkg gio-2.0 --pkg posix --pkg gmodule-2.0

FCGI_APP_FLAGS := --pkg libfcgi -X -lfcgi

include common.mk

run: lib build/simple-server build/libsetup_app.so
	$(RUNENV) build/simple-server

build/libsetup_app.so: external/setup_app.vala lib build/simple-server
	$(VALAC) $(FLAGS) $(PKGS) $(EFLAGS) --library= -X -fPIC -X -shared -o $@ $<
	rm .vapi
