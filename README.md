# tic80cc

Like [luacc][], but for TIC-80 lua projects.

[luacc]: https://github.com/mihacooper/luacc

## Requirements

 - Lua 5.3+
 - LuaCC (for building tic80cc)

## Build

```
make
```

## How to use

```
Usage: tic80cc [-o <output>] [-i <include>] [-m] [-f] [-h] <input>

Combine multiple Lua files into one.

Arguments:
   input                 The main file of the project. Must contain the metatags and data.

Options:
         -o <output>,    The filename to output to. Defaults to out.lua. (default: out.lua)
   --output <output>
          -i <include>,  A path to include in the `bundle` path.
   --include <include>
   -m, --minify          Force the minification of the code.
   -f, --force-overwrite Allows the output file to be overwritten.
   -h, --help            Show this help message and exit.
```

### Preprocessor

tic80cc provides a preprocessor for the main file and the required module.

```lua
--# comment [[Lines starting with --# are Lua code.]]

--# if true then
print("Other lines are output.")
--# end

print("A dollar sign followed by code in parentheses runs the code and inserts the result.")
print("For instance, pi is $(math.pi).")
```

#### Directives

 - `ARGS` - Not a directive, but a specially parsed line at the beginning of the file. Designates arguments. `--#ARGS (foo,bar,baz)` (note the lack of space between `#` and `ARGS`; this is the only one where that matters)
 - `include` - Include files. `--# include("filename","args","foo","bar")`, or if the file doesn't contain arguments, you can simply `--# include "filename"`.
 - `includeguard` - Prevent a file from being included more than once. `--# includeguard()`
 - `comment` - Include a comment which will not appear in the final output. `--# comment [[No comment.]]`
 - `bundle` - Add a module which will be bundled into the final output. `--# bundle "utils"`, or to define the filename specifically, `--# bundle("utils","random/directory/utils.lua")`
 - `add_path` - Add a segment to the path which is used to determine where modules are bundled from. `--# add_path "./modules/?.lua"`

## Example

A re-organization of my game, [Follow][], has been included as an example project, demonstrating bundling and including.

[Follow]: https://tic80.com/play?cart=3235
