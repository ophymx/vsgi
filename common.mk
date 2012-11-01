VER      := $(shell cat VERSION)
CC       := gcc
VALAC    := valac

NAME_LC  := $(shell echo $(NAME) | tr '[:upper:]' '[:lower:]')

LIB      := build/lib$(NAME_LC)-$(VER).so
GIR      := gir-1.0/$(NAME)-$(VER).gir
LIB_HDR  := build/$(NAME_LC)-$(VER).h
LIB_VAPI := vapi/$(NAME_LC)-$(VER).vapi

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
	$(VALAC) $(FLAGS) $(EFLAGS) -o $@ $(PKGS) $^

clean:
	rm -rf $(LIB_SRC:.vala=.c) $(EX_SRC:.vala=.c) build docs gir-1.0 \
	    $(LIB_VAPI)
