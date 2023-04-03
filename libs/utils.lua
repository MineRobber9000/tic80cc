local function string_builder()
	local ret = {string=""}
	ret.add = coroutine.wrap(function(initial)
		ret.string = ret.string .. initial
		while true do
			ret.string = ret.string .. coroutine.yield()
		end
	end)
	return ret
end

local function read_file(fn)
	local f = assert(io.open(fn,"r"),("Could not open file %q"):format(fn))
	local contents = f:read("*a")
	f:close()
	return contents
end

local function write_file(fn,contents)
	local f = assert(io.open(fn,"w"),("Could not open file %q"):format(fn))
	f:write(contents)
	f:close()
end

local function lookupify(t)
	for _,v in ipairs(t) do
		t[v]=true
	end
	return t
end

local function file_exists(fn)
	local f = io.open(fn,"r")
	if f==nil then
		return false
	end
	f:close()
	return true
end

return {
	["string_builder"]=string_builder;
	["read_file"]=read_file;
	["write_file"]=write_file;
	["lookupify"]=lookupify;
	["file_exists"]=file_exists;
}
