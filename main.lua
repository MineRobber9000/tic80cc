-- TIC-80 Code Combine
-- by MineRobber9000

local preprocessor = require"preprocessor"
local minify = require"minify"
local utils = require"utils"

local function preprocess(src,fn)
	local function inner()
	local sb = utils.string_builder()
	preprocessor.preprocess_with_directives(src,fn)(sb.add)
	return sb.string
	end
	return select(2,assert(xpcall(inner,debug.traceback)))
end

local __main = {} -- sentinel
local metatags = utils.lookupify{ -- list of the metatags which TIC-80 recognizes
	"title",
	"author",
	"desc",
	"site",
	"license",
	"version",
	"script",
	"saveid"
}
local tic80callbacks = utils.lookupify{ -- list of the callbacks TIC-80 uses
	"BDR",
	"SCN",
	"BOOT",
	"TIC",
	"OVR",
	"MENU"
}
local __bundle_template = [[-- AUTO-GENERATED CODE
-- TIC-80 Code Combine
local __tic80cc_packages = {
--# for k, v in pairs(loaded) do if type(k)=="string" then
    [$(("%q"):format(k))] = $(("%q"):format(v):gsub("\\\n","\\n"));
--# end end
}
table.insert(package.searchers,1,function(modname)
    if __tic80cc_packages[modname] then
        return load(__tic80cc_packages[modname],"="..modname)
    end
    return nil, ("no such tic80cc module %q"):format(modname)
end)
-- END AUTO-GENERATED CODE
]]
local __bundle_env_mt={__index=preprocessor.directives}
local function __gen_bundle(loaded)
	local bundle_env = setmetatable({loaded=loaded},__bundle_env_mt)
	local sb = utils.string_builder()
	preprocessor.preprocess(__bundle_template,"bundle",bundle_env)(sb.add)
	return sb.string
end
local function bundle(fn,path_elements,force_minify)
	local files = {{fn,__main}}
	local loaded = {}
	local path = "./?.lua;./?/init.lua"
	function preprocessor.directives.add_path(...)
		local args = table.pack(...)
		for i=1,args.n do
			path=path..";"..args[i]
		end
	end
	preprocessor.directives.add_path(table.unpack(path_elements or {}))
	function preprocessor.directives.bundle(name,fn)
		fn = fn or assert(package.searchpath(name,path),("cannot find module %q"):format(name))
		if loaded[name] then return end
		for i=1,#files do
			if files[i][2]==name then return end
		end
		table.insert(files,{fn,name})
	end
	while #files>0 do
		local fn, k = table.unpack(table.remove(files))
		loaded[k] = true
		loaded[k] = preprocess(utils.read_file(fn),fn)
	end
	local main = loaded[__main]
	loaded[__main] = nil
	-- ensure data remains even if we minify
	local start = main:find("\n%-%- <")
	local code, data
	if start then
		code, data = main:sub(1,start), main:sub(start+1)	
	else
		code, data = main, ""
	end
	-- ensure metatags are going to be there even if we minify
	local _metatags = ""
	local _minify = false
	for line, name, value in code:gmatch("(%-%- (%S-):%s*(.-)%s*\n)") do
		if metatags[name] then
			_metatags=_metatags..line
		elseif name=="minify" then -- minify pseudo-metatag
			_minify=tostring(value)
		end
	end
	if force_minify then _minify=true end
	local out = ""
	if _minify then
		for k,v in pairs(loaded) do
			if type(k)=="string" then
				loaded[k]=minify.minify(loaded[k],tic80callbacks)
			end
		end
		out = _metatags:gsub("%s+$","").."\n"..minify.minify(__gen_bundle(loaded).."\n"..code,tic80callbacks).."\n"..data
	else
		out = __gen_bundle(loaded)..main
	end
	return out
end

local parser = require"argparse"("tic80cc","Combine multiple Lua files into one.")
parser:argument("input","The main file of the project. Must contain the metatags and data.")
parser:option("-o --output","The filename to output to. Defaults to out.lua.","out.lua")
parser:option("-i --include","A path to include in the `bundle` path."):count"*"
parser:flag("-m --minify","Force the minification of the code.")
parser:flag("-f --force-overwrite","Allows the output file to be overwritten.")

local args = parser:parse()
local out = bundle(args.input,args.include,args.minify)
local outfile_exists = utils.file_exists(args.output)
if (not outfile_exists) or args.force_overwrite then
	utils.write_file(args.output,out)
elseif outfile_exists then
	print(("Cowardly refusing to overwrite %q."):format(args.output))
end
