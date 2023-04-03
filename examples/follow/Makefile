LUA_FILES := $(shell find . -name '*.lua')
ENTRY_POINT := main.lua

all: follow.lua follow.min.lua

follow.lua: $(LUA_FILES) tic80cc
	lua ../../tic80cc.lua -o $@ $(ENTRY_POINT) -f

follow.min.lua: $(LUA_FILES) tic80cc
	lua ../../tic80cc.lua -o $@ $(ENTRY_POINT) -fm

.PHONY: tic80cc clean
tic80cc:
	make -C ../..

clean:
	rm follow.lua follow.min.lua
