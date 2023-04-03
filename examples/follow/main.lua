-- title:   follow
-- author:  khuxkm
-- desc:    simon clone
-- license: MIT License
-- version: 0.1
-- script:  lua
-- saveid:  follow_tic80cc

local states={}
local state="title"
local function change_state(new)
	state=new
end
local funcs={}

--# comment [[Use the bundle directive to ensure modules get bundled.]]
--# bundle "states.play"
require("states.play")(states,change_state,funcs)
--# bundle "states.title"
require("states.title")(states,change_state,funcs)

function TIC()
    states[state]()
end

--# comment [[Use the include directive to include a file wholesale, as opposed to bundling.]]
--# include "data/total.lua"
--# comment [[The comment directive lets you include comments that won't even make it out of the preprocessor.]]
