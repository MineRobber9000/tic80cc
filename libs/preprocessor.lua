-- Khuxkm Lua Preprocessor (KLP)
-- an elaboration of the Slightly Less Simple Lua Preprocessor
-- original: http://lua-users.org/wiki/SlightlyLessSimpleLuaPreprocessor
-- updated by khuxkm to Lua 5.4 and with new features added
------------------------------------------------------------------------------
local function parseDollarParen(pieces, chunk, s, e)
  local s = 1
  for term, executed, e in string.gmatch(chunk, "()$(%b())()") do
      table.insert(pieces, string.format("%q..(%s or '')..",
        string.sub(chunk, s, term - 1), executed))
      s = e
  end
  table.insert(pieces, string.format("%q", string.sub(chunk, s)))
end
-------------------------------------------------------------------------------
local function parseHashLines(chunk)
  chunk = chunk:gsub("\n+$","").."\n"
  local pieces, s, args = string.find(chunk, "^%s*%-%-#ARGS%s*(%b())[ \t]*\n")
  if not args or string.find(args, "^%(%s*%)$") then
    pieces, s = {"return function(_put) ", n = 1}, s or 1
   else
    pieces = {"return function(_put, ", string.sub(args, 2), n = 2}
    s=s+1 -- hotfix for errant line at beginning of preprocessed #ARGS
  end
  while true do
    local ss, e, lua = string.find(chunk, "^%s*%-%-#+([^\n]*\n?)", s)
    if not e then
      ss, e, lua = string.find(chunk, "\n%s*%-%-#+([^\n]*\n?)", s)
      table.insert(pieces, "_put(")
      parseDollarParen(pieces, string.sub(chunk, s, ss))
      table.insert(pieces, ")")
      if not e then break end
    end
    table.insert(pieces, lua)
    s = e + 1
  end
  table.insert(pieces, " end")
  return table.concat(pieces)
end
-------------------------------------------------------------------------------
local function preprocess(chunk, name, env)
  return assert(load(parseHashLines(chunk), name, "t", env or _ENV))()
end
-------------------------------------------------------------------------------
-- Preprocessor directives for the standalone command
-------------------------------------------------------------------------------
local function getput()
    local idx=1
    local name, val = debug.getlocal(3,idx)
    repeat
        if name=="_put" then
            return val
        end
        idx=idx+1
        name, val = debug.getlocal(3,idx)
    until name==nil
end

local function getenv()
    local idx=1
    local func = debug.getinfo(3,"f").func
    local name, val = debug.getupvalue(func,idx)
    repeat
        if name=="_ENV" then
            return val
        end
        idx=idx+1
        name, val = debug.getupvalue(func,idx)
    until name==nil
end

local directives = setmetatable({},{["__index"]=_ENV})
local side_effects = {}
local preproc_env = setmetatable({},{["__index"]=directives,["__newindex"]=function(t,k,v)
    rawset(t,k,v)
    side_effects[#side_effects+1]=k
end})

local DIR_SEP = package.config:sub(1,1)
local DIR_SEP_PATTERN = "[\\/]+$"

local function join(p1,p2)
    local first_char = p2:sub(1,1)
    if first_char=="\\" or first_char=="/" then
        return p1:gsub(DIR_SEP_PATTERN,"")..p2
    end
    return p1:gsub(DIR_SEP_PATTERN,"")..DIR_SEP..p2
end

function directives.include(path,...)
    local func = getput()
    local env = getenv()
    -- resolve path
    local oldpath = (debug.getinfo(2,"S").source:match("^(.-)[\\/]?([^\\/]*)$"))
    if #oldpath==0 then oldpath="." end
    path=join(oldpath,path)
    -- include guard
    if env._guarded and env._guarded[path] then
        return
    end
    local fh = io.open(path,"r")
    if not fh then error(string.format("No such file %q",path),2) end
    local raw_code = fh:read("a"):gsub("\r\n?","\n")
    fh:close()
    local pp = preprocess(raw_code,path,preproc_env)
    local code=""
    pp(function(s) code=code..s end,...)
    func(code)
end

function directives.includeguard()
    local env = getenv()
    if not env._guarded then
        env._guarded={}
    end
    env._guarded[debug.getinfo(2,"S").source]=true
end

function directives.comment(s)
    -- do nothing
end
-- add functions to directives to add other preprocessor directives

local function preprocess_with_directives(chunk, name, keep_side_effects)
    local ret = preprocess(chunk,name,preproc_env)
    -- avoid side effects if we don't want them
    if keep_side_effects then
        -- unmark the side effects we keep
        side_effects={}
    else
        for i=1,#side_effects do
            preproc_env[side_effects[i]]=nil
        end
    end
    return ret
end

return {
    ["preprocess"]=preprocess,
    ["preprocess_with_directives"]=preprocess_with_directives,
    ["preprocess_raw"]=parseHashLines,
    ["directives"]=directives
}
