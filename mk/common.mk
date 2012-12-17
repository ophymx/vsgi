upcase = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')
downcase = $(shell echo $(1) | tr '[:upper:]' '[:lower:]')
dash2under = $(shell echo $(1) | tr '-' '_')
under2dash = $(shell echo $(1) | tr '_' '-')
example_flags = $($(call dash2under,$(call upcase,$(shell basename $@)))_FLAGS)

VER      := $(shell cat VERSION)
CC       := gcc
VALAC    := valac
FLAGS    := --vapidir=vapi --cc=$(CC) --save-temps --verbose
RUNENV   := env LD_LIBRARY_PATH="build:${LD_LIBRARY_PATH}"

PKG_NAME := $(call downcase,$(NAME))
PACKAGE  := $(PKG_NAME)-$(VER)

LIB      := build/lib$(PACKAGE).so
GIR      := gir-1.0/$(NAME)-$(VER).gir
LIB_HDR  := build/$(PACKAGE).h
LIB_VAPI := vapi/$(PACKAGE).vapi

LIB_SRC  := $(shell find 'vsgi/' -type f -name "*.vala")
LFLAGS   := -X -fPIC -X -shared --gir=$(GIR) --library=$(LIB_VAPI:.vapi=) \
            -H $(LIB_HDR) -o $(LIB)

SRV_SRC   := $(shell find 'servers/' -type f -name "*.vala")
SRV       := $(subst servers/,build/,$(SRV_SRC:.vala=))
SFLAGS    := -X -Lbuild -X -l$(PACKAGE) -X -Ibuild --pkg $(PACKAGE)

TEST_SRC := $(shell find 'tests/' -type f -name "*.vala")
TFLAGS   := -X -Lbuild -X -l$(PACKAGE) -X -Ibuild --pkg $(PACKAGE)

.PHONY: all lib servers check clean docs run

all: lib
lib: $(LIB)
servers: $(SRV)
docs: docs/index.html
check: lib build/tests
	$(RUNENV) build/tests

$(LIB): $(LIB_SRC)
	mkdir -p build gir-1.0
	$(VALAC) $(FLAGS) $(LFLAGS) $(PKGS) $(LIB_SRC)

docs/index.html: $(LIB_SRC)
	rm -rf docs
	valadoc --package-name=$(PKG_NAME) --package-version=$(VER) $(PKGS) \
	    --pkg for-docs --girdir=gir-1.0 --vapidir=vapi -o docs $^

build/tests: $(TEST_SRC) $(LIB)
	$(VALAC) $(FLAGS) $(TFLAGS) $(PKGS) -o $@ $(TEST_SRC)

build/%: servers/%.vala
	$(VALAC) $(FLAGS) $(EFLAGS) $(call example_flags) $(PKGS) -o $@ $^

clean:
	rm -rf $(LIB_SRC:.vala=.c) $(EX_SRC:.vala=.c) $(TEST_SRC:.vala=.c) \
	    build docs $(GIR) $(LIB_VAPI)
