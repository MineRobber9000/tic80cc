LIBS_FILES := $(wildcard libs/*)
LIBS := $(notdir $(basename $(LIBS_FILES)))

tic80cc.lua: main.lua $(LIBS_FILES)
	luacc -o $@ -i libs main $(LIBS)

.PHONY: clean
clean:
	rm tic80cc.lua
