upcase = $(shell echo $(1) | tr '[:lower:]' '[:upper:]')
downcase = $(shell echo $(1) | tr '[:upper:]' '[:lower:]')
dash2under = $(shell echo $(1) | tr '-' '_')
under2dash = $(shell echo $(1) | tr '_' '-')
example_flags = $($(call dash2under,$(call upcase,$(shell basename $@)))_FLAGS)

VER      := $(shell cat VERSION)
CC       := gcc
VALAC    := valac

LIB      := build/lib$(call downcase,$(NAME))-$(VER).so
GIR      := gir-1.0/$(NAME)-$(VER).gir
LIB_HDR  := build/$(call downcase,$(NAME))-$(VER).h
LIB_VAPI := vapi/$(call downcase,$(NAME))-$(VER).vapi

## Common
LIB_SRC  := $(shell find 'src/' -type f -name "*.vala")

FLAGS    := --vapidir=vapi --cc=$(CC) --save-temps --verbose
LFLAGS   := -X -fPIC -X -shared --gir=$(GIR) --library=$(LIB_VAPI:.vapi=) \
	    -H $(LIB_HDR) -o $(LIB)

EX_SRC   := $(shell find 'examples/' -type f -name "*.vala")
EX       := $(subst examples/,build/,$(EX_SRC:.vala=))
EFLAGS   := -X $(LIB) -X -Ibuild $(LIB_VAPI)

.PHONY: all lib examples test clean docs run

all: lib examples

lib: $(LIB)

$(LIB): $(LIB_SRC)
	mkdir -p build gir-1.0
	$(VALAC) $(FLAGS) $(LFLAGS) $(PKGS) $(LIB_SRC)

examples: $(EX)

build/%: examples/%.vala
	$(VALAC) $(FLAGS) $(EFLAGS) $(call example_flags) -o $@ $(PKGS) $^

clean:
	rm -rf $(LIB_SRC:.vala=.c) $(EX_SRC:.vala=.c) build docs gir-1.0 \
	    $(LIB_VAPI)
