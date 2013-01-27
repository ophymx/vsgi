NAME := VSGI
PKGS := --pkg gee-1.0 --pkg gio-2.0 --pkg posix --pkg gmodule-2.0

upcase = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')
downcase = $(shell echo $(1) | tr '[:upper:]' '[:lower:]')
dash2under = $(shell echo $(1) | tr '-' '_')
under2dash = $(shell echo $(1) | tr '_' '-')

VER      := $(shell cat VERSION)
API_VER  := 1.0
CC       := gcc
VALAC    := valac
FLAGS    := --vapidir=vapi --cc=$(CC) --save-temps -X -Ibuild -X -Lbuild \
#              --verbose
LFLAGS   := -X -fPIC -X -shared
RUNENV   := env LD_LIBRARY_PATH="build:${LD_LIBRARY_PATH}"

VSGI_NAME  := Vsgi
VSGI_PKG_NAME := $(call downcase,$(VSGI_NAME))
VSGI_PKG   := $(VSGI_PKG_NAME)-$(API_VER)

VSGI_LIB   := build/lib$(VSGI_PKG).so
VSGI_GIR   := gir-1.0/$(VSGI_NAME)-$(API_VER).gir
VSGI_HDR   := build/$(VSGI_PKG).h
VSGI_VAPI  := vapi/$(VSGI_PKG).vapi

VSGI_SRC   := $(shell find 'vsgi/' -type f -name "*.vala")
VSGI_FLAGS := --gir=$(VSGI_GIR) --library=$(VSGI_VAPI:.vapi=) -H $(VSGI_HDR) \
                -o $(VSGI_LIB)
VSGI_PKG_FLAGS := -X -l$(VSGI_PKG) --pkg $(VSGI_PKG)

FCGI_NAME  := $(VSGI_NAME)ServerFcgi
FCGI_PKG_NAME := $(call downcase,$(FCGI_NAME))
FCGI_PKG   := $(VSGI_PKG_NAME)-server-fcgi-$(API_VER)
FCGI_LIB   := build/lib$(FCGI_PKG).so
FCGI_GIR   := gir-1.0/$(FCGI_NAME)-$(API_VER).gir
FCGI_HDR   := build/$(FCGI_PKG).h
FCGI_VAPI  := vapi/$(FCGI_PKG).vapi
FCGI_SRC   := $(shell find 'servers/fcgi/lib' -type f -name "*.vala")
FCGI_BIN_SRC := $(shell find 'servers/fcgi/bin' -type f -name "*.vala")
FCGI_FLAGS := --gir=$(FCGI_GIR) --library=$(FCGI_VAPI:.vapi=) -H $(FCGI_HDR) \
                -o $(FCGI_LIB)
FCGI_PKG_FLAGS := -X -l$(FCGI_PKG) --pkg $(FCGI_PKG)

SIMPLE_NAME  := $(VSGI_NAME)ServerSimple
SIMPLE_PKG_NAME := $(call downcase,$(SIMPLE_NAME))
SIMPLE_PKG   := $(VSGI_PKG_NAME)-server-simple-$(API_VER)
SIMPLE_LIB   := build/lib$(SIMPLE_PKG).so
SIMPLE_GIR   := gir-1.0/$(SIMPLE_NAME)-$(API_VER).gir
SIMPLE_HDR   := build/$(SIMPLE_PKG).h
SIMPLE_VAPI  := vapi/$(SIMPLE_PKG).vapi
SIMPLE_SRC   := $(shell find 'servers/simple/lib' -type f -name "*.vala")
SIMPLE_BIN_SRC := $(shell find 'servers/simple/bin' -type f -name "*.vala")
SIMPLE_FLAGS := --gir=$(SIMPLE_GIR) --library=$(SIMPLE_VAPI:.vapi=) \
                  -H $(SIMPLE_HDR) -o $(SIMPLE_LIB)
SIMPLE_PKG_FLAGS := -X -l$(SIMPLE_PKG) --pkg $(SIMPLE_PKG)

TEST_SRC := $(shell find 'tests/' -type f -name "*.vala")

.PHONY: all
all: lib servers
.PHONY: lib
lib: $(VSGI_LIB) $(SIMPLE_LIB) $(FCGI_LIB)
.PHONY: servers
servers: build/fcgi-server build/simple-server
.PHONY: docs
docs: docs/index.html
.PHONY: check
check: lib build/tests
	$(RUNENV) build/tests

$(VSGI_LIB): $(VSGI_SRC)
	mkdir -p build gir-1.0
	$(VALAC) $(FLAGS) $(LFLAGS) $(VSGI_FLAGS) $(PKGS) $(VSGI_SRC)

$(SIMPLE_LIB): $(VSGI_LIB) $(SIMPLE_SRC)
	mkdir -p build gir-1.0
	$(VALAC) $(FLAGS) $(LFLAGS) $(SIMPLE_FLAGS) $(VSGI_PKG_FLAGS) \
	  $(SIMPLE_SRC)

build/simple-server: $(SIMPLE_LIB) $(SIMPLE_BIN_SRC)
	$(VALAC) $(FLAGS) -o $@ $(SIMPLE_PKG_FLAGS) $(VSGI_PKG_FLAGS) \
	    --pkg posix $(SIMPLE_BIN_SRC)

$(FCGI_LIB): $(VSGI_LIB) $(FCGI_SRC)
	mkdir -p build gir-1.0
	$(VALAC) $(FLAGS) $(LFLAGS) $(FCGI_FLAGS) $(VSGI_PKG_FLAGS) $(FCGI_SRC)\
	  --pkg fcgi -X -lfcgi

build/fcgi-server: $(FCGI_LIB) $(FCGI_BIN_SRC)
	$(VALAC) $(FLAGS) -o $@ $(VSGI_PKG_FLAGS) $(FCGI_PKG_FLAGS) \
	    --pkg posix $(FCGI_BIN_SRC)

build/tests: $(TEST_SRC) $(LIB)
	$(VALAC) $(FLAGS) $(VSGI_PKG_FLAGS) $(FCGI_PKG_FLAGS) \
	    $(SIMPLE_PKG_FLAGS) -o $@ $(TEST_SRC)

docs/index.html: $(VSGI_SRC) $(FCGI_SRC) $(SIMPLE_SRC)
	rm -rf docs
	valadoc --package-name=$(VSGI_PKG_NAME) --package-version=$(API_VER) \
	    $(PKGS) --pkg for-docs --pkg fcgi --girdir=gir-1.0 --vapidir=vapi \
	    -o docs $^

build/setup_app.so: $(VSGI_LIB) $(SIMPLE_LIB) $(FCGI_LIB) \
    examples/setup_app.vala
	$(VALAC) $(FLAGS) $(PKGS) $(VSGI_PKG_FLAGS) --library= $(LFLAGS) \
	    -o $@ examples/setup_app.vala
	rm .vapi

.PHONY: run
run: build/simple-server build/setup_app.so
	$(RUNENV) build/simple-server

.PHONY: clean
clean:
	rm -rf $(VSGI_SRC:.vala=.c) $(FCGI_SRC:.vala=.c) $(TEST_SRC:.vala=.c) \
	    $(SIMPLE_SRC:.vala=.c) $(FCGI_BIN_SRC:.vala=.c) \
	    $(SIMPLE_BIN_SRC:.vala=.c) build docs gir-1.0 $(VSGI_VAPI) \
	    $(FCGI_VAPI) $(SIMPLE_VAPI) examples/setup_app.c
