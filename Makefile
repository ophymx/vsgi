LIBDIR := build/lib
BINDIR := build/bin
INCLUDE_DIR := build/include
VAPIDIR := build/share/vala/vapi
GIRDIR := build/share/gir-1.0
PKG_CONFIG_DIR := build/lib/pkgconfig

get_src = $(shell find $(1) -type f -name '*.vala')
get_pkgs = $(shell cat $(1)/.deps)
get_deps = $(addprefix --pkg ,$(call get_pkgs,$(1)))

CC     ?= gcc
VALAC  ?= valac
FLAGS  := --vapidir=vapi --vapidir=$(VAPIDIR) \
	--girdir=gir-1.0 --girdir=$(GIRDIR) \
	--cc=$(CC) --save-temps --verbose

PKG_CONFIG = PKG_CONFIG_PATH="$(PKG_CONFIG_DIR):$(PKG_CONFIG_PATH)"

LFLAGS := -X -fPIC -X -shared

MKDIRS := mkdir -p $(LIBDIR) $(BINDIR) $(INCLUDE_DIR) $(VAPIDIR) $(GIRDIR) \
	$(PKG_CONFIG_DIR)

RUNENV := LD_LIBRARY_PATH="$(LIBDIR):$(LD_LIBRARY_PATH)" \
	    PATH="$(BINDIR):$(PATH)"

PKG_CONFIG_BUILD = 's,@prefix@,build,; s,@exec_prefix@,$${prefix},; \
    s,@libdir@,$${prefix}/lib,; s,@includedir@,$${prefix}/include,; \
    s,@datarootdir@,$${prefix}/share,; s,@sdatadir@,$${datarootdir},;'

LIBS = $(addsuffix .so,$(addprefix $(LIBDIR)/lib,$(shell ls 'src/lib')))
SERVERS = $(addprefix $(BINDIR)/,$(shell ls 'src/bin'))

.PHONY: all
all: lib servers

.PHONY: lib
lib: $(LIBS)

.PHONY: servers
servers: $(SERVERS)

.PHONY: docs
docs: docs/index.html

.PHONY: test
test: lib build/tests
	$(RUNENV) build/tests

libvsgi_SRC = $(call get_src,'src/lib/vsgi')
$(LIBDIR)/libvsgi.so: $(libvsgi_SRC)
	$(MKDIRS)
	$(VALAC) $(FLAGS) $(LFLAGS) -o $@ \
	    $(call get_deps,'src/lib/vsgi') \
	    --gir=$(GIRDIR)/VSGI-1.0.gir \
	    --library=$(VAPIDIR)/vsgi-1.0 \
	    --header=$(INCLUDE_DIR)/vsgi.h \
	    $(libvsgi_SRC)
	cp src/lib/vsgi/.deps $(VAPIDIR)/vsgi-1.0.deps
	sed -e $(PKG_CONFIG_BUILD) src/lib/vsgi/vsgi-1.0.pc.in > \
	    $(PKG_CONFIG_DIR)/vsgi-1.0.pc

libvsgi_server_simple_SRC = $(call get_src,'src/lib/vsgi-server-simple')
$(LIBDIR)/libvsgi-server-simple.so: $(VSGI_LIB) $(libvsgi_server_simple_SRC)
	$(MKDIRS)
	$(PKG_CONFIG) $(VALAC) $(FLAGS) $(LFLAGS) -o $@ \
	    $(call get_deps,'src/lib/vsgi-server-simple') \
	    --gir=$(GIRDIR)/VSGIServerSimple-1.0.gir \
	    --library=$(VAPIDIR)/vsgi-server-simple-1.0 \
	    --header=$(INCLUDE_DIR)/vsgi-server-simple.h \
	    $(libvsgi_server_simple_SRC)
	cp src/lib/vsgi-server-simple/.deps \
	    $(VAPIDIR)/vsgi-server-simple-1.0.deps
	sed -e $(PKG_CONFIG_BUILD) \
	    src/lib/vsgi-server-simple/vsgi-server-simple-1.0.pc.in > \
	    $(PKG_CONFIG_DIR)/vsgi-server-simple-1.0.pc

vsgi_server_simple_SRC = $(call get_src,'src/bin/vsgi-server-simple')
$(BINDIR)/vsgi-server-simple: $(SIMPLE_LIB) $(vsgi_server_simple_SRC)
	$(PKG_CONFIG) $(VALAC) $(FLAGS) \
	    $(call get_deps,'src/bin/vsgi-server-simple') -o $@ \
	    $(vsgi_server_simple_SRC)

libvsgi_server_fcgi_SRC = $(call get_src,'src/lib/vsgi-server-fcgi')
$(LIBDIR)/libvsgi-server-fcgi.so: $(VSGI_LIB) $(libvsgi_server_fcgi_SRC)
	$(MKDIRS)
	$(PKG_CONFIG) $(VALAC) $(FLAGS) $(LFLAGS) -o $@ \
	    $(call get_deps,'src/lib/vsgi-server-fcgi') \
    	    --pkg fcgi -X -lfcgi \
	    --gir=$(GIRDIR)/VSGIServerFcgi-1.0.gir \
	    --library=$(VAPIDIR)/vsgi-server-fcgi-1.0 \
	    --header=$(INCLUDE_DIR)/vsgi-server-fcgi.h \
	    $(libvsgi_server_fcgi_SRC)
	cp src/lib/vsgi-server-fcgi/.deps $(VAPIDIR)/vsgi-server-fcgi-1.0.deps
	sed -e $(PKG_CONFIG_BUILD) \
	    src/lib/vsgi-server-fcgi/vsgi-server-fcgi-1.0.pc.in > \
	    $(PKG_CONFIG_DIR)/vsgi-server-fcgi-1.0.pc

vsgi_server_fcgi_SRC = $(call get_src,'src/bin/vsgi-server-fcgi')
$(BINDIR)/vsgi-server-fcgi: $(FCGI_LIB) $(vsgi_server_fcgi_SRC)
	$(PKG_CONFIG) $(VALAC) $(FLAGS) \
	    $(call get_deps,'src/bin/vsgi-server-fcgi') -o $@ \
	    $(vsgi_server_fcgi_SRC)

TEST_SRC = $(shell find 'tests/' -type f -name "*.vala")
build/tests: $(LIBS) $(TEST_SRC)
	$(PKG_CONFIG) $(VALAC) $(FLAGS) $(call get_deps,'tests') -o $@ $(TEST_SRC)

docs/index.html: $(call get_src,'src/lib')
	rm -rf docs
	valadoc --package-name=$(VSGI_PKG_NAME) --package-version=$(API_VER) \
	    --vapidir=vapi --vapidir=$(VAPIDIR) \
	    $(call get_deps,'src/lib/vsgi') --pkg for-docs --pkg fcgi  \
	    -o docs $^

$(LIBDIR)/setup_app.so: $(LIBDIR)/libvsgi.so examples/setup_app.vala
	$(PKG_CONFIG) $(VALAC) $(FLAGS) $(LFLAGS) -o $@ --library= \
	    --pkg vsgi-1.0 examples/setup_app.vala
	rm .vapi

.PHONY: run
run: $(BINDIR)/vsgi-server-simple $(LIBDIR)/setup_app.so
	$(RUNENV) $(BINDIR)/vsgi-server-simple

.PHONY: context
context:
	env $(RUNENV) bash -i

.PHONY: clean
SRC = $(call get_src,'src') $(call get_src,'tests') $(call get_src,'examples')
clean:
	rm -rf $(SRC:.vala=.c) build docs
