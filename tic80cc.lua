
---------------------------------------------------------
----------------Auto generated code block----------------
---------------------------------------------------------

do
    local searchers = package.searchers or package.loaders
    local origin_seacher = searchers[2]
    searchers[2] = function(path)
        local files =
        {
------------------------
-- Modules part begin --
------------------------

["argparse"] = function()
--------------------
-- Module: 'argparse'
--------------------
-- The MIT License (MIT)

-- Copyright (c) 2013 - 2018 Peter Melnichenko

-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local function deep_update(t1, t2)
   for k, v in pairs(t2) do
      if type(v) == "table" then
         v = deep_update({}, v)
      end

      t1[k] = v
   end

   return t1
end

-- A property is a tuple {name, callback}.
-- properties.args is number of properties that can be set as arguments
-- when calling an object.
local function class(prototype, properties, parent)
   -- Class is the metatable of its instances.
   local cl = {}
   cl.__index = cl

   if parent then
      cl.__prototype = deep_update(deep_update({}, parent.__prototype), prototype)
   else
      cl.__prototype = prototype
   end

   if properties then
      local names = {}

      -- Create setter methods and fill set of property names.
      for _, property in ipairs(properties) do
         local name, callback = property[1], property[2]

         cl[name] = function(self, value)
            if not callback(self, value) then
               self["_" .. name] = value
            end

            return self
         end

         names[name] = true
      end

      function cl.__call(self, ...)
         -- When calling an object, if the first argument is a table,
         -- interpret keys as property names, else delegate arguments
         -- to corresponding setters in order.
         if type((...)) == "table" then
            for name, value in pairs((...)) do
               if names[name] then
                  self[name](self, value)
               end
            end
         else
            local nargs = select("#", ...)

            for i, property in ipairs(properties) do
               if i > nargs or i > properties.args then
                  break
               end

               local arg = select(i, ...)

               if arg ~= nil then
                  self[property[1]](self, arg)
               end
            end
         end

         return self
      end
   end

   -- If indexing class fails, fallback to its parent.
   local class_metatable = {}
   class_metatable.__index = parent

   function class_metatable.__call(self, ...)
      -- Calling a class returns its instance.
      -- Arguments are delegated to the instance.
      local object = deep_update({}, self.__prototype)
      setmetatable(object, self)
      return object(...)
   end

   return setmetatable(cl, class_metatable)
end

local function typecheck(name, types, value)
   for _, type_ in ipairs(types) do
      if type(value) == type_ then
         return true
      end
   end

   error(("bad property '%s' (%s expected, got %s)"):format(name, table.concat(types, " or "), type(value)))
end

local function typechecked(name, ...)
   local types = {...}
   return {name, function(_, value) typecheck(name, types, value) end}
end

local multiname = {"name", function(self, value)
   typecheck("name", {"string"}, value)

   for alias in value:gmatch("%S+") do
      self._name = self._name or alias
      table.insert(self._aliases, alias)
   end

   -- Do not set _name as with other properties.
   return true
end}

local function parse_boundaries(str)
   if tonumber(str) then
      return tonumber(str), tonumber(str)
   end

   if str == "*" then
      return 0, math.huge
   end

   if str == "+" then
      return 1, math.huge
   end

   if str == "?" then
      return 0, 1
   end

   if str:match "^%d+%-%d+$" then
      local min, max = str:match "^(%d+)%-(%d+)$"
      return tonumber(min), tonumber(max)
   end

   if str:match "^%d+%+$" then
      local min = str:match "^(%d+)%+$"
      return tonumber(min), math.huge
   end
end

local function boundaries(name)
   return {name, function(self, value)
      typecheck(name, {"number", "string"}, value)

      local min, max = parse_boundaries(value)

      if not min then
         error(("bad property '%s'"):format(name))
      end

      self["_min" .. name], self["_max" .. name] = min, max
   end}
end

local actions = {}

local option_action = {"action", function(_, value)
   typecheck("action", {"function", "string"}, value)

   if type(value) == "string" and not actions[value] then
      error(("unknown action '%s'"):format(value))
   end
end}

local option_init = {"init", function(self)
   self._has_init = true
end}

local option_default = {"default", function(self, value)
   if type(value) ~= "string" then
      self._init = value
      self._has_init = true
      return true
   end
end}

local add_help = {"add_help", function(self, value)
   typecheck("add_help", {"boolean", "string", "table"}, value)

   if self._has_help then
      table.remove(self._options)
      self._has_help = false
   end

   if value then
      local help = self:flag()
         :description "Show this help message and exit."
         :action(function()
            print(self:get_help())
            os.exit(0)
         end)

      if value ~= true then
         help = help(value)
      end

      if not help._name then
         help "-h" "--help"
      end

      self._has_help = true
   end
end}

local Parser = class({
   _arguments = {},
   _options = {},
   _commands = {},
   _mutexes = {},
   _groups = {},
   _require_command = true,
   _handle_options = true
}, {
   args = 3,
   typechecked("name", "string"),
   typechecked("description", "string"),
   typechecked("epilog", "string"),
   typechecked("usage", "string"),
   typechecked("help", "string"),
   typechecked("require_command", "boolean"),
   typechecked("handle_options", "boolean"),
   typechecked("action", "function"),
   typechecked("command_target", "string"),
   typechecked("help_vertical_space", "number"),
   typechecked("usage_margin", "number"),
   typechecked("usage_max_width", "number"),
   typechecked("help_usage_margin", "number"),
   typechecked("help_description_margin", "number"),
   typechecked("help_max_width", "number"),
   add_help
})

local Command = class({
   _aliases = {}
}, {
   args = 3,
   multiname,
   typechecked("description", "string"),
   typechecked("epilog", "string"),
   typechecked("target", "string"),
   typechecked("usage", "string"),
   typechecked("help", "string"),
   typechecked("require_command", "boolean"),
   typechecked("handle_options", "boolean"),
   typechecked("action", "function"),
   typechecked("command_target", "string"),
   typechecked("help_vertical_space", "number"),
   typechecked("usage_margin", "number"),
   typechecked("usage_max_width", "number"),
   typechecked("help_usage_margin", "number"),
   typechecked("help_description_margin", "number"),
   typechecked("help_max_width", "number"),
   typechecked("hidden", "boolean"),
   add_help
}, Parser)

local Argument = class({
   _minargs = 1,
   _maxargs = 1,
   _mincount = 1,
   _maxcount = 1,
   _defmode = "unused",
   _show_default = true
}, {
   args = 5,
   typechecked("name", "string"),
   typechecked("description", "string"),
   option_default,
   typechecked("convert", "function", "table"),
   boundaries("args"),
   typechecked("target", "string"),
   typechecked("defmode", "string"),
   typechecked("show_default", "boolean"),
   typechecked("argname", "string", "table"),
   typechecked("hidden", "boolean"),
   option_action,
   option_init
})

local Option = class({
   _aliases = {},
   _mincount = 0,
   _overwrite = true
}, {
   args = 6,
   multiname,
   typechecked("description", "string"),
   option_default,
   typechecked("convert", "function", "table"),
   boundaries("args"),
   boundaries("count"),
   typechecked("target", "string"),
   typechecked("defmode", "string"),
   typechecked("show_default", "boolean"),
   typechecked("overwrite", "boolean"),
   typechecked("argname", "string", "table"),
   typechecked("hidden", "boolean"),
   option_action,
   option_init
}, Argument)

function Parser:_inherit_property(name, default)
   local element = self

   while true do
      local value = element["_" .. name]

      if value ~= nil then
         return value
      end

      if not element._parent then
         return default
      end

      element = element._parent
   end
end

function Argument:_get_argument_list()
   local buf = {}
   local i = 1

   while i <= math.min(self._minargs, 3) do
      local argname = self:_get_argname(i)

      if self._default and self._defmode:find "a" then
         argname = "[" .. argname .. "]"
      end

      table.insert(buf, argname)
      i = i+1
   end

   while i <= math.min(self._maxargs, 3) do
      table.insert(buf, "[" .. self:_get_argname(i) .. "]")
      i = i+1

      if self._maxargs == math.huge then
         break
      end
   end

   if i < self._maxargs then
      table.insert(buf, "...")
   end

   return buf
end

function Argument:_get_usage()
   local usage = table.concat(self:_get_argument_list(), " ")

   if self._default and self._defmode:find "u" then
      if self._maxargs > 1 or (self._minargs == 1 and not self._defmode:find "a") then
         usage = "[" .. usage .. "]"
      end
   end

   return usage
end

function actions.store_true(result, target)
   result[target] = true
end

function actions.store_false(result, target)
   result[target] = false
end

function actions.store(result, target, argument)
   result[target] = argument
end

function actions.count(result, target, _, overwrite)
   if not overwrite then
      result[target] = result[target] + 1
   end
end

function actions.append(result, target, argument, overwrite)
   result[target] = result[target] or {}
   table.insert(result[target], argument)

   if overwrite then
      table.remove(result[target], 1)
   end
end

function actions.concat(result, target, arguments, overwrite)
   if overwrite then
      error("'concat' action can't handle too many invocations")
   end

   result[target] = result[target] or {}

   for _, argument in ipairs(arguments) do
      table.insert(result[target], argument)
   end
end

function Argument:_get_action()
   local action, init

   if self._maxcount == 1 then
      if self._maxargs == 0 then
         action, init = "store_true", nil
      else
         action, init = "store", nil
      end
   else
      if self._maxargs == 0 then
         action, init = "count", 0
      else
         action, init = "append", {}
      end
   end

   if self._action then
      action = self._action
   end

   if self._has_init then
      init = self._init
   end

   if type(action) == "string" then
      action = actions[action]
   end

   return action, init
end

-- Returns placeholder for `narg`-th argument.
function Argument:_get_argname(narg)
   local argname = self._argname or self:_get_default_argname()

   if type(argname) == "table" then
      return argname[narg]
   else
      return argname
   end
end

function Argument:_get_default_argname()
   return "<" .. self._name .. ">"
end

function Option:_get_default_argname()
   return "<" .. self:_get_default_target() .. ">"
end

-- Returns labels to be shown in the help message.
function Argument:_get_label_lines()
   return {self._name}
end

function Option:_get_label_lines()
   local argument_list = self:_get_argument_list()

   if #argument_list == 0 then
      -- Don't put aliases for simple flags like `-h` on different lines.
      return {table.concat(self._aliases, ", ")}
   end

   local longest_alias_length = -1

   for _, alias in ipairs(self._aliases) do
      longest_alias_length = math.max(longest_alias_length, #alias)
   end

   local argument_list_repr = table.concat(argument_list, " ")
   local lines = {}

   for i, alias in ipairs(self._aliases) do
      local line = (" "):rep(longest_alias_length - #alias) .. alias .. " " .. argument_list_repr

      if i ~= #self._aliases then
         line = line .. ","
      end

      table.insert(lines, line)
   end

   return lines
end

function Command:_get_label_lines()
   return {table.concat(self._aliases, ", ")}
end

function Argument:_get_description()
   if self._default and self._show_default then
      if self._description then
         return ("%s (default: %s)"):format(self._description, self._default)
      else
         return ("default: %s"):format(self._default)
      end
   else
      return self._description or ""
   end
end

function Command:_get_description()
   return self._description or ""
end

function Option:_get_usage()
   local usage = self:_get_argument_list()
   table.insert(usage, 1, self._name)
   usage = table.concat(usage, " ")

   if self._mincount == 0 or self._default then
      usage = "[" .. usage .. "]"
   end

   return usage
end

function Argument:_get_default_target()
   return self._name
end

function Option:_get_default_target()
   local res

   for _, alias in ipairs(self._aliases) do
      if alias:sub(1, 1) == alias:sub(2, 2) then
         res = alias:sub(3)
         break
      end
   end

   res = res or self._name:sub(2)
   return (res:gsub("-", "_"))
end

function Option:_is_vararg()
   return self._maxargs ~= self._minargs
end

function Parser:_get_fullname()
   local parent = self._parent
   local buf = {self._name}

   while parent do
      table.insert(buf, 1, parent._name)
      parent = parent._parent
   end

   return table.concat(buf, " ")
end

function Parser:_update_charset(charset)
   charset = charset or {}

   for _, command in ipairs(self._commands) do
      command:_update_charset(charset)
   end

   for _, option in ipairs(self._options) do
      for _, alias in ipairs(option._aliases) do
         charset[alias:sub(1, 1)] = true
      end
   end

   return charset
end

function Parser:argument(...)
   local argument = Argument(...)
   table.insert(self._arguments, argument)
   return argument
end

function Parser:option(...)
   local option = Option(...)

   if self._has_help then
      table.insert(self._options, #self._options, option)
   else
      table.insert(self._options, option)
   end

   return option
end

function Parser:flag(...)
   return self:option():args(0)(...)
end

function Parser:command(...)
   local command = Command():add_help(true)(...)
   command._parent = self
   table.insert(self._commands, command)
   return command
end

function Parser:mutex(...)
   local elements = {...}

   for i, element in ipairs(elements) do
      local mt = getmetatable(element)
      assert(mt == Option or mt == Argument, ("bad argument #%d to 'mutex' (Option or Argument expected)"):format(i))
   end

   table.insert(self._mutexes, elements)
   return self
end

function Parser:group(name, ...)
   assert(type(name) == "string", ("bad argument #1 to 'group' (string expected, got %s)"):format(type(name)))

   local group = {name = name, ...}

   for i, element in ipairs(group) do
      local mt = getmetatable(element)
      assert(mt == Option or mt == Argument or mt == Command,
         ("bad argument #%d to 'group' (Option or Argument or Command expected)"):format(i + 1))
   end

   table.insert(self._groups, group)
   return self
end

local usage_welcome = "Usage: "

function Parser:get_usage()
   if self._usage then
      return self._usage
   end

   local usage_margin = self:_inherit_property("usage_margin", #usage_welcome)
   local max_usage_width = self:_inherit_property("usage_max_width", 70)
   local lines = {usage_welcome .. self:_get_fullname()}

   local function add(s)
      if #lines[#lines]+1+#s <= max_usage_width then
         lines[#lines] = lines[#lines] .. " " .. s
      else
         lines[#lines+1] = (" "):rep(usage_margin) .. s
      end
   end

   -- Normally options are before positional arguments in usage messages.
   -- However, vararg options should be after, because they can't be reliable used
   -- before a positional argument.
   -- Mutexes come into play, too, and are shown as soon as possible.
   -- Overall, output usages in the following order:
   -- 1. Mutexes that don't have positional arguments or vararg options.
   -- 2. Options that are not in any mutexes and are not vararg.
   -- 3. Positional arguments - on their own or as a part of a mutex.
   -- 4. Remaining mutexes.
   -- 5. Remaining options.

   local elements_in_mutexes = {}
   local added_elements = {}
   local added_mutexes = {}
   local argument_to_mutexes = {}

   local function add_mutex(mutex, main_argument)
      if added_mutexes[mutex] then
         return
      end

      added_mutexes[mutex] = true
      local buf = {}

      for _, element in ipairs(mutex) do
         if not element._hidden and not added_elements[element] then
            if getmetatable(element) == Option or element == main_argument then
               table.insert(buf, element:_get_usage())
               added_elements[element] = true
            end
         end
      end

      if #buf == 1 then
         add(buf[1])
      elseif #buf > 1 then
         add("(" .. table.concat(buf, " | ") .. ")")
      end
   end

   local function add_element(element)
      if not element._hidden and not added_elements[element] then
         add(element:_get_usage())
         added_elements[element] = true
      end
   end

   for _, mutex in ipairs(self._mutexes) do
      local is_vararg = false
      local has_argument = false

      for _, element in ipairs(mutex) do
         if getmetatable(element) == Option then
            if element:_is_vararg() then
               is_vararg = true
            end
         else
            has_argument = true
            argument_to_mutexes[element] = argument_to_mutexes[element] or {}
            table.insert(argument_to_mutexes[element], mutex)
         end

         elements_in_mutexes[element] = true
      end

      if not is_vararg and not has_argument then
         add_mutex(mutex)
      end
   end

   for _, option in ipairs(self._options) do
      if not elements_in_mutexes[option] and not option:_is_vararg() then
         add_element(option)
      end
   end

   -- Add usages for positional arguments, together with one mutex containing them, if they are in a mutex.
   for _, argument in ipairs(self._arguments) do
      -- Pick a mutex as a part of which to show this argument, take the first one that's still available.
      local mutex

      if elements_in_mutexes[argument] then
         for _, argument_mutex in ipairs(argument_to_mutexes[argument]) do
            if not added_mutexes[argument_mutex] then
               mutex = argument_mutex
            end
         end
      end

      if mutex then
         add_mutex(mutex, argument)
      else
         add_element(argument)
      end
   end

   for _, mutex in ipairs(self._mutexes) do
      add_mutex(mutex)
   end

   for _, option in ipairs(self._options) do
      add_element(option)
   end

   if #self._commands > 0 then
      if self._require_command then
         add("<command>")
      else
         add("[<command>]")
      end

      add("...")
   end

   return table.concat(lines, "\n")
end

local function split_lines(s)
   if s == "" then
      return {}
   end

   local lines = {}

   if s:sub(-1) ~= "\n" then
      s = s .. "\n"
   end

   for line in s:gmatch("([^\n]*)\n") do
      table.insert(lines, line)
   end

   return lines
end

local function autowrap_line(line, max_length)
   -- Algorithm for splitting lines is simple and greedy.
   local result_lines = {}

   -- Preserve original indentation of the line, put this at the beginning of each result line.
   -- If the first word looks like a list marker ('*', '+', or '-'), add spaces so that starts
   -- of the second and the following lines vertically align with the start of the second word.
   local indentation = line:match("^ *")

   if line:find("^ *[%*%+%-]") then
      indentation = indentation .. " " .. line:match("^ *[%*%+%-]( *)")
   end

   -- Parts of the last line being assembled.
   local line_parts = {}

   -- Length of the current line.
   local line_length = 0

   -- Index of the next character to consider.
   local index = 1

   while true do
      local word_start, word_finish, word = line:find("([^ ]+)", index)

      if not word_start then
         -- Ignore trailing spaces, if any.
         break
      end

      local preceding_spaces = line:sub(index, word_start - 1)
      index = word_finish + 1

      if (#line_parts == 0) or (line_length + #preceding_spaces + #word <= max_length) then
         -- Either this is the very first word or it fits as an addition to the current line, add it.
         table.insert(line_parts, preceding_spaces) -- For the very first word this adds the indentation.
         table.insert(line_parts, word)
         line_length = line_length + #preceding_spaces + #word
      else
         -- Does not fit, finish current line and put the word into a new one.
         table.insert(result_lines, table.concat(line_parts))
         line_parts = {indentation, word}
         line_length = #indentation + #word
      end
   end

   if #line_parts > 0 then
      table.insert(result_lines, table.concat(line_parts))
   end

   if #result_lines == 0 then
      -- Preserve empty lines.
      result_lines[1] = ""
   end

   return result_lines
end

-- Automatically wraps lines within given array,
-- attempting to limit line length to `max_length`.
-- Existing line splits are preserved.
local function autowrap(lines, max_length)
   local result_lines = {}

   for _, line in ipairs(lines) do
      local autowrapped_lines = autowrap_line(line, max_length)

      for _, autowrapped_line in ipairs(autowrapped_lines) do
         table.insert(result_lines, autowrapped_line)
      end
   end

   return result_lines
end

function Parser:_get_element_help(element)
   local label_lines = element:_get_label_lines()
   local description_lines = split_lines(element:_get_description())

   local result_lines = {}

   -- All label lines should have the same length (except the last one, it has no comma).
   -- If too long, start description after all the label lines.
   -- Otherwise, combine label and description lines.

   local usage_margin_len = self:_inherit_property("help_usage_margin", 3)
   local usage_margin = (" "):rep(usage_margin_len)
   local description_margin_len = self:_inherit_property("help_description_margin", 25)
   local description_margin = (" "):rep(description_margin_len)

   local help_max_width = self:_inherit_property("help_max_width")

   if help_max_width then
      local description_max_width = math.max(help_max_width - description_margin_len, 10)
      description_lines = autowrap(description_lines, description_max_width)
   end

   if #label_lines[1] >= (description_margin_len - usage_margin_len) then
      for _, label_line in ipairs(label_lines) do
         table.insert(result_lines, usage_margin .. label_line)
      end

      for _, description_line in ipairs(description_lines) do
         table.insert(result_lines, description_margin .. description_line)
      end
   else
      for i = 1, math.max(#label_lines, #description_lines) do
         local label_line = label_lines[i]
         local description_line = description_lines[i]

         local line = ""

         if label_line then
            line = usage_margin .. label_line
         end

         if description_line and description_line ~= "" then
            line = line .. (" "):rep(description_margin_len - #line) .. description_line
         end

         table.insert(result_lines, line)
      end
   end

   return table.concat(result_lines, "\n")
end

local function get_group_types(group)
   local types = {}

   for _, element in ipairs(group) do
      types[getmetatable(element)] = true
   end

   return types
end

function Parser:_add_group_help(blocks, added_elements, label, elements)
   local buf = {label}

   for _, element in ipairs(elements) do
      if not element._hidden and not added_elements[element] then
         added_elements[element] = true
         table.insert(buf, self:_get_element_help(element))
      end
   end

   if #buf > 1 then
      table.insert(blocks, table.concat(buf, ("\n"):rep(self:_inherit_property("help_vertical_space", 0) + 1)))
   end
end

function Parser:get_help()
   if self._help then
      return self._help
   end

   local blocks = {self:get_usage()}

   local help_max_width = self:_inherit_property("help_max_width")

   if self._description then
      local description = self._description

      if help_max_width then
         description = table.concat(autowrap(split_lines(description), help_max_width), "\n")
      end

      table.insert(blocks, description)
   end

   -- 1. Put groups containing arguments first, then other arguments.
   -- 2. Put remaining groups containing options, then other options.
   -- 3. Put remaining groups containing commands, then other commands.
   -- Assume that an element can't be in several groups.
   local groups_by_type = {
      [Argument] = {},
      [Option] = {},
      [Command] = {}
   }

   for _, group in ipairs(self._groups) do
      local group_types = get_group_types(group)

      for _, mt in ipairs({Argument, Option, Command}) do
         if group_types[mt] then
            table.insert(groups_by_type[mt], group)
            break
         end
      end
   end

   local default_groups = {
      {name = "Arguments", type = Argument, elements = self._arguments},
      {name = "Options", type = Option, elements = self._options},
      {name = "Commands", type = Command, elements = self._commands}
   }

   local added_elements = {}

   for _, default_group in ipairs(default_groups) do
      local type_groups = groups_by_type[default_group.type]

      for _, group in ipairs(type_groups) do
         self:_add_group_help(blocks, added_elements, group.name .. ":", group)
      end

      local default_label = default_group.name .. ":"

      if #type_groups > 0 then
         default_label = "Other " .. default_label:gsub("^.", string.lower)
      end

      self:_add_group_help(blocks, added_elements, default_label, default_group.elements)
   end

   if self._epilog then
      local epilog = self._epilog

      if help_max_width then
         epilog = table.concat(autowrap(split_lines(epilog), help_max_width), "\n")
      end

      table.insert(blocks, epilog)
   end

   return table.concat(blocks, "\n\n")
end

local function get_tip(context, wrong_name)
   local context_pool = {}
   local possible_name
   local possible_names = {}

   for name in pairs(context) do
      if type(name) == "string" then
         for i = 1, #name do
            possible_name = name:sub(1, i - 1) .. name:sub(i + 1)

            if not context_pool[possible_name] then
               context_pool[possible_name] = {}
            end

            table.insert(context_pool[possible_name], name)
         end
      end
   end

   for i = 1, #wrong_name + 1 do
      possible_name = wrong_name:sub(1, i - 1) .. wrong_name:sub(i + 1)

      if context[possible_name] then
         possible_names[possible_name] = true
      elseif context_pool[possible_name] then
         for _, name in ipairs(context_pool[possible_name]) do
            possible_names[name] = true
         end
      end
   end

   local first = next(possible_names)

   if first then
      if next(possible_names, first) then
         local possible_names_arr = {}

         for name in pairs(possible_names) do
            table.insert(possible_names_arr, "'" .. name .. "'")
         end

         table.sort(possible_names_arr)
         return "\nDid you mean one of these: " .. table.concat(possible_names_arr, " ") .. "?"
      else
         return "\nDid you mean '" .. first .. "'?"
      end
   else
      return ""
   end
end

local ElementState = class({
   invocations = 0
})

function ElementState:__call(state, element)
   self.state = state
   self.result = state.result
   self.element = element
   self.target = element._target or element:_get_default_target()
   self.action, self.result[self.target] = element:_get_action()
   return self
end

function ElementState:error(fmt, ...)
   self.state:error(fmt, ...)
end

function ElementState:convert(argument, index)
   local converter = self.element._convert

   if converter then
      local ok, err

      if type(converter) == "function" then
         ok, err = converter(argument)
      elseif type(converter[index]) == "function" then
         ok, err = converter[index](argument)
      else
         ok = converter[argument]
      end

      if ok == nil then
         self:error(err and "%s" or "malformed argument '%s'", err or argument)
      end

      argument = ok
   end

   return argument
end

function ElementState:default(mode)
   return self.element._defmode:find(mode) and self.element._default
end

local function bound(noun, min, max, is_max)
   local res = ""

   if min ~= max then
      res = "at " .. (is_max and "most" or "least") .. " "
   end

   local number = is_max and max or min
   return res .. tostring(number) .. " " .. noun ..  (number == 1 and "" or "s")
end

function ElementState:set_name(alias)
   self.name = ("%s '%s'"):format(alias and "option" or "argument", alias or self.element._name)
end

function ElementState:invoke()
   self.open = true
   self.overwrite = false

   if self.invocations >= self.element._maxcount then
      if self.element._overwrite then
         self.overwrite = true
      else
         local num_times_repr = bound("time", self.element._mincount, self.element._maxcount, true)
         self:error("%s must be used %s", self.name, num_times_repr)
      end
   else
      self.invocations = self.invocations + 1
   end

   self.args = {}

   if self.element._maxargs <= 0 then
      self:close()
   end

   return self.open
end

function ElementState:pass(argument)
   argument = self:convert(argument, #self.args + 1)
   table.insert(self.args, argument)

   if #self.args >= self.element._maxargs then
      self:close()
   end

   return self.open
end

function ElementState:complete_invocation()
   while #self.args < self.element._minargs do
      self:pass(self.element._default)
   end
end

function ElementState:close()
   if self.open then
      self.open = false

      if #self.args < self.element._minargs then
         if self:default("a") then
            self:complete_invocation()
         else
            if #self.args == 0 then
               if getmetatable(self.element) == Argument then
                  self:error("missing %s", self.name)
               elseif self.element._maxargs == 1 then
                  self:error("%s requires an argument", self.name)
               end
            end

            self:error("%s requires %s", self.name, bound("argument", self.element._minargs, self.element._maxargs))
         end
      end

      local args

      if self.element._maxargs == 0 then
         args = self.args[1]
      elseif self.element._maxargs == 1 then
         if self.element._minargs == 0 and self.element._mincount ~= self.element._maxcount then
            args = self.args
         else
            args = self.args[1]
         end
      else
         args = self.args
      end

      self.action(self.result, self.target, args, self.overwrite)
   end
end

local ParseState = class({
   result = {},
   options = {},
   arguments = {},
   argument_i = 1,
   element_to_mutexes = {},
   mutex_to_element_state = {},
   command_actions = {}
})

function ParseState:__call(parser, error_handler)
   self.parser = parser
   self.error_handler = error_handler
   self.charset = parser:_update_charset()
   self:switch(parser)
   return self
end

function ParseState:error(fmt, ...)
   self.error_handler(self.parser, fmt:format(...))
end

function ParseState:switch(parser)
   self.parser = parser

   if parser._action then
      table.insert(self.command_actions, {action = parser._action, name = parser._name})
   end

   for _, option in ipairs(parser._options) do
      option = ElementState(self, option)
      table.insert(self.options, option)

      for _, alias in ipairs(option.element._aliases) do
         self.options[alias] = option
      end
   end

   for _, mutex in ipairs(parser._mutexes) do
      for _, element in ipairs(mutex) do
         if not self.element_to_mutexes[element] then
            self.element_to_mutexes[element] = {}
         end

         table.insert(self.element_to_mutexes[element], mutex)
      end
   end

   for _, argument in ipairs(parser._arguments) do
      argument = ElementState(self, argument)
      table.insert(self.arguments, argument)
      argument:set_name()
      argument:invoke()
   end

   self.handle_options = parser._handle_options
   self.argument = self.arguments[self.argument_i]
   self.commands = parser._commands

   for _, command in ipairs(self.commands) do
      for _, alias in ipairs(command._aliases) do
         self.commands[alias] = command
      end
   end
end

function ParseState:get_option(name)
   local option = self.options[name]

   if not option then
      self:error("unknown option '%s'%s", name, get_tip(self.options, name))
   else
      return option
   end
end

function ParseState:get_command(name)
   local command = self.commands[name]

   if not command then
      if #self.commands > 0 then
         self:error("unknown command '%s'%s", name, get_tip(self.commands, name))
      else
         self:error("too many arguments")
      end
   else
      return command
   end
end

function ParseState:check_mutexes(element_state)
   if self.element_to_mutexes[element_state.element] then
      for _, mutex in ipairs(self.element_to_mutexes[element_state.element]) do
         local used_element_state = self.mutex_to_element_state[mutex]

         if used_element_state and used_element_state ~= element_state then
            self:error("%s can not be used together with %s", element_state.name, used_element_state.name)
         else
            self.mutex_to_element_state[mutex] = element_state
         end
      end
   end
end

function ParseState:invoke(option, name)
   self:close()
   option:set_name(name)
   self:check_mutexes(option, name)

   if option:invoke() then
      self.option = option
   end
end

function ParseState:pass(arg)
   if self.option then
      if not self.option:pass(arg) then
         self.option = nil
      end
   elseif self.argument then
      self:check_mutexes(self.argument)

      if not self.argument:pass(arg) then
         self.argument_i = self.argument_i + 1
         self.argument = self.arguments[self.argument_i]
      end
   else
      local command = self:get_command(arg)
      self.result[command._target or command._name] = true

      if self.parser._command_target then
         self.result[self.parser._command_target] = command._name
      end

      self:switch(command)
   end
end

function ParseState:close()
   if self.option then
      self.option:close()
      self.option = nil
   end
end

function ParseState:finalize()
   self:close()

   for i = self.argument_i, #self.arguments do
      local argument = self.arguments[i]
      if #argument.args == 0 and argument:default("u") then
         argument:complete_invocation()
      else
         argument:close()
      end
   end

   if self.parser._require_command and #self.commands > 0 then
      self:error("a command is required")
   end

   for _, option in ipairs(self.options) do
      option.name = option.name or ("option '%s'"):format(option.element._name)

      if option.invocations == 0 then
         if option:default("u") then
            option:invoke()
            option:complete_invocation()
            option:close()
         end
      end

      local mincount = option.element._mincount

      if option.invocations < mincount then
         if option:default("a") then
            while option.invocations < mincount do
               option:invoke()
               option:close()
            end
         elseif option.invocations == 0 then
            self:error("missing %s", option.name)
         else
            self:error("%s must be used %s", option.name, bound("time", mincount, option.element._maxcount))
         end
      end
   end

   for i = #self.command_actions, 1, -1 do
      self.command_actions[i].action(self.result, self.command_actions[i].name)
   end
end

function ParseState:parse(args)
   for _, arg in ipairs(args) do
      local plain = true

      if self.handle_options then
         local first = arg:sub(1, 1)

         if self.charset[first] then
            if #arg > 1 then
               plain = false

               if arg:sub(2, 2) == first then
                  if #arg == 2 then
                     if self.options[arg] then
                        local option = self:get_option(arg)
                        self:invoke(option, arg)
                     else
                        self:close()
                     end

                     self.handle_options = false
                  else
                     local equals = arg:find "="
                     if equals then
                        local name = arg:sub(1, equals - 1)
                        local option = self:get_option(name)

                        if option.element._maxargs <= 0 then
                           self:error("option '%s' does not take arguments", name)
                        end

                        self:invoke(option, name)
                        self:pass(arg:sub(equals + 1))
                     else
                        local option = self:get_option(arg)
                        self:invoke(option, arg)
                     end
                  end
               else
                  for i = 2, #arg do
                     local name = first .. arg:sub(i, i)
                     local option = self:get_option(name)
                     self:invoke(option, name)

                     if i ~= #arg and option.element._maxargs > 0 then
                        self:pass(arg:sub(i + 1))
                        break
                     end
                  end
               end
            end
         end
      end

      if plain then
         self:pass(arg)
      end
   end

   self:finalize()
   return self.result
end

function Parser:error(msg)
   io.stderr:write(("%s\n\nError: %s\n"):format(self:get_usage(), msg))
   os.exit(1)
end

-- Compatibility with strict.lua and other checkers:
local default_cmdline = rawget(_G, "arg") or {}

function Parser:_parse(args, error_handler)
   return ParseState(self, error_handler):parse(args or default_cmdline)
end

function Parser:parse(args)
   return self:_parse(args, self.error)
end

local function xpcall_error_handler(err)
   return tostring(err) .. "\noriginal " .. debug.traceback("", 2):sub(2)
end

function Parser:pparse(args)
   local parse_error

   local ok, result = xpcall(function()
      return self:_parse(args, function(_, err)
         parse_error = err
         error(err, 0)
      end)
   end, xpcall_error_handler)

   if ok then
      return true, result
   elseif not parse_error then
      error(result, 0)
   else
      return false, parse_error
   end
end

local argparse = {}

argparse.version = "0.6.0"

setmetatable(argparse, {__call = function(_, ...)
   return Parser(default_cmdline[0]):add_help(true)(...)
end})

return argparse

end,

["minify"] = function()
--------------------
-- Module: 'minify'
--------------------
--[[
MIT License

Copyright (c) 2017 Mark Langen, 2023 Robert Miles

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

function lookupify(tb)
	for _, v in pairs(tb) do
		tb[v] = true
	end
	return tb
end

function CountTable(tb)
	local c = 0
	for _ in pairs(tb) do c = c + 1 end
	return c
end

function FormatTableInt(tb, atIndent, ignoreFunc)
	if tb.Print then
		return tb.Print()
	end
	atIndent = atIndent or 0
	local useNewlines = (CountTable(tb) > 1)
	local baseIndent = string.rep('    ', atIndent+1)
	local out = "{"..(useNewlines and '\n' or '')
	for k, v in pairs(tb) do
		if type(v) ~= 'function' and not ignoreFunc(k) then
			out = out..(useNewlines and baseIndent or '')
			if type(k) == 'number' then
				--nothing to do
			elseif type(k) == 'string' and k:match("^[A-Za-z_][A-Za-z0-9_]*$") then 
				out = out..k.." = "
			elseif type(k) == 'string' then
				out = out.."[\""..k.."\"] = "
			else
				out = out.."["..tostring(k).."] = "
			end
			if type(v) == 'string' then
				out = out.."\""..v.."\""
			elseif type(v) == 'number' then
				out = out..v
			elseif type(v) == 'table' then
				out = out..FormatTableInt(v, atIndent+(useNewlines and 1 or 0), ignoreFunc)
			else
				out = out..tostring(v)
			end
			if next(tb, k) then
				out = out..","
			end
			if useNewlines then
				out = out..'\n'
			end
		end
	end
	out = out..(useNewlines and string.rep('    ', atIndent) or '').."}"
	return out
end

function FormatTable(tb, ignoreFunc)
	ignoreFunc = ignoreFunc or function() 
		return false 
	end
	return FormatTableInt(tb, 0, ignoreFunc)
end

local WhiteChars = lookupify{' ', '\n', '\t', '\r'}

local AllIdentStartChars = lookupify{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                                     'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                                     's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                                     'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
                                     'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 
                                     'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '_'}

local AllIdentChars = lookupify{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
                                'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
                                's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 
                                'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 
                                'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '_',
                                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

local Digits = lookupify{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

local HexDigits = lookupify{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
                            'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'E', 'e', 'F', 'f'}

local Symbols = lookupify{'+', '-', '*', '/', '^', '%', ',', '{', '}', '[', ']', '(', ')', ';', '#', '.', ':', '~', '&', '|'}

local EqualSymbols = lookupify{'~', '=', '>', '<'}

local Keywords = lookupify{
    'and', 'break', 'do', 'else', 'elseif',
    'end', 'false', 'for', 'function', 'goto', 'if',
    'in', 'local', 'nil', 'not', 'or', 'repeat',
    'return', 'then', 'true', 'until', 'while',
};

local BlockFollowKeyword = lookupify{'else', 'elseif', 'until', 'end'}

local UnopSet = lookupify{'-', 'not', '#', '~'}

local BinopSet = lookupify{
	'+', '-', '*', '/', '//', '%', '^', '#',
	'..', '.', ':', '>>', '<<', '&', '|', '~',
	'>', '<', '<=', '>=', '~=', '==',
	'and', 'or'
}

local GlobalRenameIgnore = lookupify{

}

local BinaryPriority = {
   ['+'] = {10, 10};
   ['-'] = {10, 10};
   ['*'] = {11, 11};
   ['/'] = {11, 11};
   ['//'] = {11, 11};
   ['%'] = {11, 11};
   ['^'] = {14, 13};
   ['&'] = {6, 6};
   ['|'] = {4, 4};
   ['~'] = {5, 5};
   ['<<'] = {7, 7};
   ['>>'] = {7, 7};
   ['..'] = {9, 8};
   ['=='] = {3, 3};
   ['~='] = {3, 3};
   ['>'] = {3, 3};
   ['<'] = {3, 3};
   ['>='] = {3, 3};
   ['<='] = {3, 3};
   ['and'] = {2, 2};
   ['or'] = {1, 1};
};
local UnaryPriority = 8

-- Eof, Ident, Keyword, Number, String, Symbol

function CreateLuaTokenStream(text)
	-- Tracking for the current position in the buffer, and
	-- the current line / character we are on.
	local p = 1
	local length = #text

	-- Output buffer for tokens
	local tokenBuffer = {}

	-- Get a character, or '' if at eof
	local function look(n)
		n = p + (n or 0)
		if n <= length then
			return text:sub(n, n)
		else
			return ''
		end
	end
	local function get()
		if p <= length then
			local c = text:sub(p, p)
			p = p + 1
			return c
		else
			return ''
		end
	end

	-- Error
	local olderr = error
	local function error(str)
		local q = 1
		local line = 1
		local char = 1
		while q <= p do
			if text:sub(q, q) == '\n' then
				line = line + 1
				char = 1
			else
				char = char + 1
			end
			q = q + 1
		end
		for _, token in pairs(tokenBuffer) do
			print(token.Type.."<"..token.Source..">")
		end
		olderr("file<"..line..":"..char..">: "..str)
	end

	-- Consume a long data with equals count of `eqcount'
	local function longdata(eqcount)
		while true do
			local c = get()
			if c == '' then
				error("Unfinished long string.")
			elseif c == ']' then
				local done = true -- Until contested
				for i = 1, eqcount do
					if look() == '=' then
						p = p + 1
					else
						done = false
						break
					end
				end
				if done and get() == ']' then
					return
				end
			end
		end
	end

	-- Get the opening part for a long data `[` `=`* `[`
	-- Precondition: The first `[` has been consumed
	-- Return: nil or the equals count
	local function getopen()
		local startp = p
		while look() == '=' do
			p = p + 1
		end
		if look() == '[' then
			p = p + 1
			return p - startp - 1
		else
			p = startp
			return nil
		end
	end

	-- Add token
	local whiteStart = 1
	local tokenStart = 1
	local function token(type)
		local tk = {
			Type = type;
			LeadingWhite = text:sub(whiteStart, tokenStart-1);
			Source = text:sub(tokenStart, p-1);
		}
		table.insert(tokenBuffer, tk)
		whiteStart = p
		tokenStart = p
		return tk
	end

	-- Parse tokens loop
	while true do
		-- Mark the whitespace start
		whiteStart = p

		-- Get the leading whitespace + comments
		while true do
			local c = look()
			if c == '' then
				break
			elseif c == '-' then
				if look(1) == '-' then
					p = p + 2
					-- Consume comment body
					if look() == '[' then
						p = p + 1
						local eqcount = getopen()
						if eqcount then
							-- Long comment body
							longdata(eqcount)
						else
							-- Normal comment body
							while true do
								local c2 = get()
								if c2 == '' or c2 == '\n' then
									break
								end
							end
						end
					else
						-- Normal comment body
						while true do
							local c2 = get()
							if c2 == '' or c2 == '\n' then
								break
							end
						end
					end
				else
					break
				end
			elseif WhiteChars[c] then
				p = p + 1
			else
				break
			end
		end
		local leadingWhite = text:sub(whiteStart, p-1)

		-- Mark the token start
		tokenStart = p

		-- Switch on token type
		local c1 = get()
		if c1 == '' then
			-- End of file
			token('Eof')
			break
		elseif c1 == '\'' or c1 == '\"' then
			-- String constant
			while true do
				local c2 = get()
				if c2 == '\\' then
					get() -- get escaped character
				elseif c2 == c1 then
					break
				end
			end
			token('String')
		elseif AllIdentStartChars[c1] then
			-- Ident or Keyword
			while AllIdentChars[look()] do
				p = p + 1
			end
			if Keywords[text:sub(tokenStart, p-1)] then
				token('Keyword')
			else
				token('Ident')
			end
		elseif Digits[c1] or (c1 == '.' and Digits[look()]) then
			-- Number
			if c1 == '0' and look() == 'x' then
				p = p + 1
				-- Hex number
				while HexDigits[look()] do
					p = p + 1
				end
			else
				-- Normal Number
				while Digits[look()] do
					p = p + 1
				end
				if look() == '.' then
					-- With decimal point
					p = p + 1
					while Digits[look()] do
						p = p + 1
					end
				end
				if look() == 'e' or look() == 'E' then
					-- With exponent
					p = p + 1
					if look() == '-' then
						p = p + 1
					end
					while Digits[look()] do
						p = p + 1
					end
				end
			end
			token('Number')
		elseif c1 == '[' then
			-- '[' Symbol or Long String
			local eqCount = getopen()
			if eqCount then
				-- Long string
				longdata(eqCount)
				token('String')
			else
				-- Symbol
				token('Symbol')
			end
		elseif c1 == '.' then
			-- Greedily consume up to 3 `.` for . / .. / ... tokens
			if look() == '.' then
				get()
				if look() == '.' then
					get()
				end
			end
			token('Symbol')
		elseif EqualSymbols[c1] then
			if look() == '=' then
				p = p + 1
			elseif (c1=='>' or c1=='<') and c1==look() then
				p = p + 1
			end
			token('Symbol')
		elseif Symbols[c1] then
			if c1=='/' and look()==c1 then
				p = p + 1
			end
			token('Symbol')
		else
			error("Bad symbol `"..c1.."` in source.")
		end
	end
	return tokenBuffer
end

function CreateLuaParser(text)
	-- Token stream and pointer into it
	local tokens = CreateLuaTokenStream(text)
	-- for _, tok in pairs(tokens) do
	-- 	print(tok.Type..": "..tok.Source)
	-- end
	local p = 1

	local function get()
		local tok = tokens[p]
		if p < #tokens then
			p = p + 1
		end
		return tok
	end
	local function peek(n)
		n = p + (n or 0)
		return tokens[n] or tokens[#tokens]
	end

	local function getTokenStartPosition(token)
		local line = 1
		local char = 0
		local tkNum = 1
		while true do
			local tk = tokens[tkNum]
			local text;
			if tk == token then
				text = tk.LeadingWhite
			else
				text = tk.LeadingWhite..tk.Source
			end
			for i = 1, #text do
				local c = text:sub(i, i)
				if c == '\n' then
					line = line + 1
					char = 0
				else
					char = char + 1
				end
			end
			if tk == token then
				break
			end
			tkNum = tkNum + 1
		end
		return line..":"..(char+1)
	end
	local function debugMark()
		local tk = peek()
		return "<"..tk.Type.." `"..tk.Source.."`> at: "..getTokenStartPosition(tk)
	end

	local function isBlockFollow()
		local tok = peek()
		return tok.Type == 'Eof' or (tok.Type == 'Keyword' and BlockFollowKeyword[tok.Source])
	end	
	local function isUnop()
		return UnopSet[peek().Source] or false
	end
	local function isBinop()
		return BinopSet[peek().Source] or false
	end
	local function expect(type, source)
		local tk = peek()
		if tk.Type == type and (source == nil or tk.Source == source) then
			return get()
		else
			for i = -3, 3 do
				print("Tokens["..i.."] = `"..peek(i).Source.."`")
			end
			if source then
				error(getTokenStartPosition(tk)..": `"..source.."` expected.")
			else
				error(getTokenStartPosition(tk)..": "..type.." expected.")
			end
		end
	end

	local function MkNode(node)
		local getf = node.GetFirstToken
		local getl = node.GetLastToken
		function node:GetFirstToken()
			local t = getf(self)
			assert(t)
			return t
		end
		function node:GetLastToken()
			local t = getl(self)
			assert(t)
			return t
		end
		return node
	end

	-- Forward decls
	local block;
	local expr;

	-- Expression list
	local function exprlist()
		local exprList = {}
		local commaList = {}
		table.insert(exprList, expr())
		while peek().Source == ',' do
			table.insert(commaList, get())
			table.insert(exprList, expr())
		end
		return exprList, commaList
	end

	local function prefixexpr()
		local tk = peek()
		if tk.Source == '(' then
			local oparenTk = get()
			local inner = expr()
			local cparenTk = expect('Symbol', ')')
			return MkNode{
				Type = 'ParenExpr';
				Expression = inner;
				Token_OpenParen = oparenTk;
				Token_CloseParen = cparenTk;
				GetFirstToken = function(self)
					return self.Token_OpenParen
				end;
				GetLastToken = function(self)
					return self.Token_CloseParen
				end;
			}
		elseif tk.Type == 'Ident' then
			return MkNode{
				Type = 'VariableExpr';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		else
			print(debugMark())
			error(getTokenStartPosition(tk)..": Unexpected symbol")
		end
	end

	function tableexpr()
		local obrace = expect('Symbol', '{')
		local entries = {}
		local separators = {}
		while peek().Source ~= '}' do
			if peek().Source == '[' then
				-- Index
				local obrac = get()
				local index = expr()
				local cbrac = expect('Symbol', ']')
				local eq = expect('Symbol', '=')
				local value = expr()
				table.insert(entries, {
					EntryType = 'Index';
					Index = index;
					Value = value;
					Token_OpenBracket = obrac;
					Token_CloseBracket = cbrac;
					Token_Equals = eq;
				})
			elseif peek().Type == 'Ident' and peek(1).Source == '=' then
				-- Field
				local field = get()
				local eq = get()
				local value = expr()
				table.insert(entries, {
					EntryType = 'Field';
					Field = field;
					Value = value;
					Token_Equals = eq;
				})
			else
				-- Value
				local value = expr()
				table.insert(entries, {
					EntryType = 'Value';
					Value = value;
				})
			end

			-- Comma or Semicolon separator
			if peek().Source == ',' or peek().Source == ';' then
				table.insert(separators, get())
			else
				break
			end
		end
		local cbrace = expect('Symbol', '}')
		return MkNode{
			Type = 'TableLiteral';
			EntryList = entries;
			Token_SeparatorList = separators;
			Token_OpenBrace = obrace;
			Token_CloseBrace = cbrace;
			GetFirstToken = function(self)
				return self.Token_OpenBrace
			end;
			GetLastToken = function(self)
				return self.Token_CloseBrace
			end;
		}
	end

	-- List of identifiers
	local function varlist()
		local varList = {}
		local commaList = {}
		if peek().Type == 'Ident' then
			table.insert(varList, get())
		end
		while peek().Source == ',' do
			table.insert(commaList, get())
			local id = expect('Ident')
			table.insert(varList, id)
		end
		return varList, commaList
	end

	-- Body
	local function blockbody(terminator)
		local body = block()
		local after = peek()
		if after.Type == 'Keyword' and after.Source == terminator then
			get()
			return body, after
		else
			print(after.Type, after.Source)
			error(getTokenStartPosition(after)..": "..terminator.." expected.")
		end
	end

	-- Function declaration
	local function funcdecl(isAnonymous)
		local functionKw = get()
		--
		local nameChain;
		local nameChainSeparator;
		--
		if not isAnonymous then
			nameChain = {}
			nameChainSeparator = {}
			--
			table.insert(nameChain, expect('Ident'))
			--
			while peek().Source == '.' do
				table.insert(nameChainSeparator, get())
				table.insert(nameChain, expect('Ident'))
			end
			if peek().Source == ':' then
				table.insert(nameChainSeparator, get())
				table.insert(nameChain, expect('Ident'))
			end
		end
		--
		local oparenTk = expect('Symbol', '(')
		local argList, argCommaList = varlist()
		local cparenTk = expect('Symbol', ')')
		local fbody, enTk = blockbody('end')
		--
		return MkNode{
			Type = (isAnonymous and 'FunctionLiteral' or 'FunctionStat');
			NameChain = nameChain;
			ArgList = argList;
			Body = fbody;
			--
			Token_Function = functionKw;
			Token_NameChainSeparator = nameChainSeparator;
			Token_OpenParen = oparenTk;
			Token_ArgCommaList = argCommaList;
			Token_CloseParen = cparenTk;
			Token_End = enTk;
			GetFirstToken = function(self)
				return self.Token_Function
			end;
			GetLastToken = function(self)
				return self.Token_End;
			end;
		}
	end

	-- Argument list passed to a funciton
	local function functionargs()
		local tk = peek()
		if tk.Source == '(' then
			local oparenTk = get()
			local argList = {}
			local argCommaList = {}
			while peek().Source ~= ')' do
				table.insert(argList, expr())
				if peek().Source == ',' then
					table.insert(argCommaList, get())
				else
					break
				end
			end
			local cparenTk = expect('Symbol', ')')
			return MkNode{
				CallType = 'ArgCall';
				ArgList = argList;
				--
				Token_CommaList = argCommaList;
				Token_OpenParen = oparenTk;
				Token_CloseParen = cparenTk;
				GetFirstToken = function(self)
					return self.Token_OpenParen
				end;
				GetLastToken = function(self)
					return self.Token_CloseParen
				end;
			}
		elseif tk.Source == '{' then
			return MkNode{
				CallType = 'TableCall';
				TableExpr = expr();
				GetFirstToken = function(self)
					return self.TableExpr:GetFirstToken()
				end;
				GetLastToken = function(self)
					return self.TableExpr:GetLastToken()
				end;
			}
		elseif tk.Type == 'String' then
			return MkNode{
				CallType = 'StringCall';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		else
			error("Function arguments expected.")
		end
	end

	local function primaryexpr()
		local base = prefixexpr()
		assert(base, "nil prefixexpr")
		while true do
			local tk = peek()
			if tk.Source == '.' then
				local dotTk = get()
				local fieldName = expect('Ident')
				base = MkNode{
					Type = 'FieldExpr';
					Base = base;
					Field = fieldName;
					Token_Dot = dotTk;
					GetFirstToken = function(self)
						return self.Base:GetFirstToken()
					end;
					GetLastToken = function(self)
						return self.Field
					end;
				}
			elseif tk.Source == ':' then
				local colonTk = get()
				local methodName = expect('Ident')
				local fargs = functionargs()
				base = MkNode{
					Type = 'MethodExpr';
					Base = base;
					Method = methodName;
					FunctionArguments = fargs;
					Token_Colon = colonTk;
					GetFirstToken = function(self)
						return self.Base:GetFirstToken()
					end;
					GetLastToken = function(self)
						return self.FunctionArguments:GetLastToken()
					end;
				}
			elseif tk.Source == '[' then
				local obrac = get()
				local index = expr()
				local cbrac = expect('Symbol', ']')
				base = MkNode{
					Type = 'IndexExpr';
					Base = base;
					Index = index;
					Token_OpenBracket = obrac;
					Token_CloseBracket = cbrac;
					GetFirstToken = function(self)
						return self.Base:GetFirstToken()
					end;
					GetLastToken = function(self)
						return self.Token_CloseBracket
					end;
				}
			elseif tk.Source == '{' then
				base = MkNode{
					Type = 'CallExpr';
					Base = base;
					FunctionArguments = functionargs();
					GetFirstToken = function(self)
						return self.Base:GetFirstToken()
					end;
					GetLastToken = function(self)
						return self.FunctionArguments:GetLastToken()
					end;
				}
			elseif tk.Source == '(' then
				base = MkNode{
					Type = 'CallExpr';
					Base = base;
					FunctionArguments = functionargs();
					GetFirstToken = function(self)
						return self.Base:GetFirstToken()
					end;
					GetLastToken = function(self)
						return self.FunctionArguments:GetLastToken()
					end;
				}
			else
				return base
			end
		end
	end

	local function simpleexpr()
		local tk = peek()
		if tk.Type == 'Number' then
			return MkNode{
				Type = 'NumberLiteral';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		elseif tk.Type == 'String' then
			return MkNode{
				Type = 'StringLiteral';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		elseif tk.Source == 'nil' then
			return MkNode{
				Type = 'NilLiteral';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		elseif tk.Source == 'true' or tk.Source == 'false' then
			return MkNode{
				Type = 'BooleanLiteral';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		elseif tk.Source == '...' then
			return MkNode{
				Type = 'VargLiteral';
				Token = get();
				GetFirstToken = function(self)
					return self.Token
				end;
				GetLastToken = function(self)
					return self.Token
				end;
			}
		elseif tk.Source == '{' then
			return tableexpr()
		elseif tk.Source == 'function' then
			return funcdecl(true)
		else
			return primaryexpr()
		end
	end

	local function subexpr(limit)
		local curNode;

		-- Initial Base Expression
		if isUnop() then
			local opTk = get()
			local ex = subexpr(UnaryPriority)
			curNode = MkNode{
				Type = 'UnopExpr';
				Token_Op = opTk;
				Rhs = ex;
				GetFirstToken = function(self)
					return self.Token_Op
				end;
				GetLastToken = function(self)
					return self.Rhs:GetLastToken()
				end;
			}
		else 
			curNode = simpleexpr()
			assert(curNode, "nil simpleexpr")
		end

		-- Apply Precedence Recursion Chain
		while isBinop() and BinaryPriority[peek().Source][1] > limit do
			local opTk = get()
			local rhs = subexpr(BinaryPriority[opTk.Source][2])
			assert(rhs, "RhsNeeded")
			curNode = MkNode{
				Type = 'BinopExpr';
				Lhs = curNode;
				Rhs = rhs;
				Token_Op = opTk;
				GetFirstToken = function(self)
					return self.Lhs:GetFirstToken()
				end;
				GetLastToken = function(self)
					return self.Rhs:GetLastToken()
				end;
			}
		end

		-- Return result
		return curNode
	end

	-- Expression
	expr = function()
		return subexpr(0)
	end

	-- Expression statement
	local function exprstat()
		local ex = primaryexpr()
		if ex.Type == 'MethodExpr' or ex.Type == 'CallExpr' then
			-- all good, calls can be statements
			return MkNode{
				Type = 'CallExprStat';
				Expression = ex;
				GetFirstToken = function(self)
					return self.Expression:GetFirstToken()
				end;
				GetLastToken = function(self)
					return self.Expression:GetLastToken()
				end;
			}
		else
			-- Assignment expr
			local lhs = {ex}
			local lhsSeparator = {}
			while peek().Source == ',' do
				table.insert(lhsSeparator, get())
				local lhsPart = primaryexpr()
				if lhsPart.Type == 'MethodExpr' or lhsPart.Type == 'CallExpr' then
					error("Bad left hand side of assignment")
				end
				table.insert(lhs, lhsPart)
			end
			local eq = expect('Symbol', '=')
			local rhs = {expr()}
			local rhsSeparator = {}
			while peek().Source == ',' do
				table.insert(rhsSeparator, get())
				table.insert(rhs, expr())
			end
			return MkNode{
				Type = 'AssignmentStat';
				Rhs = rhs;
				Lhs = lhs;
				Token_Equals = eq;
				Token_LhsSeparatorList = lhsSeparator;
				Token_RhsSeparatorList = rhsSeparator;
				GetFirstToken = function(self)
					return self.Lhs[1]:GetFirstToken()
				end;
				GetLastToken = function(self)
					return self.Rhs[#self.Rhs]:GetLastToken()
				end;
			}
		end
	end

	-- If statement
	local function ifstat()
		local ifKw = get()
		local condition = expr()
		local thenKw = expect('Keyword', 'then')
		local ifBody = block()
		local elseClauses = {}
		while peek().Source == 'elseif' or peek().Source == 'else' do
			local elseifKw = get()
			local elseifCondition, elseifThenKw;
			if elseifKw.Source == 'elseif' then
				elseifCondition = expr()
				elseifThenKw = expect('Keyword', 'then')
			end
			local elseifBody = block()
			table.insert(elseClauses, {
				Condition = elseifCondition;
				Body = elseifBody;
				--
				ClauseType = elseifKw.Source;
				Token = elseifKw;
				Token_Then = elseifThenKw;
			})
			if elseifKw.Source == 'else' then
				break
			end
		end
		local enKw = expect('Keyword', 'end')
		return MkNode{
			Type = 'IfStat';
			Condition = condition;
			Body = ifBody;
			ElseClauseList = elseClauses;
			--
			Token_If = ifKw;
			Token_Then = thenKw;
			Token_End = enKw;
			GetFirstToken = function(self)
				return self.Token_If
			end;
			GetLastToken = function(self)
				return self.Token_End
			end;
		}
	end

	-- Do statement
	local function dostat()
		local doKw = get()
		local body, enKw = blockbody('end')
		--
		return MkNode{
			Type = 'DoStat';
			Body = body;
			--
			Token_Do = doKw;
			Token_End = enKw;
			GetFirstToken = function(self)
				return self.Token_Do
			end;
			GetLastToken = function(self)
				return self.Token_End
			end;
		}
	end

	-- While statement
	local function whilestat()
		local whileKw = get()
		local condition = expr()
		local doKw = expect('Keyword', 'do')
		local body, enKw = blockbody('end')
		--
		return MkNode{
			Type = 'WhileStat';
			Condition = condition;
			Body = body;
			--
			Token_While = whileKw;
			Token_Do = doKw;
			Token_End = enKw;
			GetFirstToken = function(self)
				return self.Token_While
			end;
			GetLastToken = function(self)
				return self.Token_End
			end;
		}
	end

	-- For statement
	local function forstat()
		local forKw = get()
		local loopVars, loopVarCommas = varlist()
		local node = {}
		if peek().Source == '=' then
			local eqTk = get()
			local exprList, exprCommaList = exprlist()
			if #exprList < 2 or #exprList > 3 then
				error("expected 2 or 3 values for range bounds")
			end
			local doTk = expect('Keyword', 'do')
			local body, enTk = blockbody('end')
			return MkNode{
				Type = 'NumericForStat';
				VarList = loopVars;
				RangeList = exprList;
				Body = body;
				--
				Token_For = forKw;
				Token_VarCommaList = loopVarCommas;
				Token_Equals = eqTk;
				Token_RangeCommaList = exprCommaList;
				Token_Do = doTk;
				Token_End = enTk;
				GetFirstToken = function(self)
					return self.Token_For
				end;
				GetLastToken = function(self)
					return self.Token_End
				end;
			}
		elseif peek().Source == 'in' then
			local inTk = get()
			local exprList, exprCommaList = exprlist()
			local doTk = expect('Keyword', 'do')
			local body, enTk = blockbody('end')
			return MkNode{
				Type = 'GenericForStat';
				VarList = loopVars;
				GeneratorList = exprList;
				Body = body;
				--
				Token_For = forKw;
				Token_VarCommaList = loopVarCommas;
				Token_In = inTk;
				Token_GeneratorCommaList = exprCommaList;
				Token_Do = doTk;
				Token_End = enTk;
				GetFirstToken = function(self)
					return self.Token_For
				end;
				GetLastToken = function(self)
					return self.Token_End
				end;
			}
		else
			error("`=` or in expected")
		end
	end

	-- Repeat statement
	local function repeatstat()
		local repeatKw = get()
		local body, untilTk = blockbody('until')
		local condition = expr()
		return MkNode{
			Type = 'RepeatStat';
			Body = body;
			Condition = condition;
			--
			Token_Repeat = repeatKw;
			Token_Until = untilTk;
			GetFirstToken = function(self)
				return self.Token_Repeat
			end;
			GetLastToken = function(self)
				return self.Condition:GetLastToken()
			end;
		}
	end

	-- Local var declaration
	local function localdecl()
		local localKw = get()
		if peek().Source == 'function' then
			-- Local function def
			local funcStat = funcdecl(false)
			if #funcStat.NameChain > 1 then
				error(getTokenStartPosition(funcStat.Token_NameChainSeparator[1])..": `(` expected.")
			end
			return MkNode{
				Type = 'LocalFunctionStat';
				FunctionStat = funcStat;
				Token_Local = localKw;
				GetFirstToken = function(self)
					return self.Token_Local
				end;
				GetLastToken = function(self)
					return self.FunctionStat:GetLastToken()
				end;
			}
		elseif peek().Type == 'Ident' then
			-- Local variable declaration
			local varList, varCommaList = varlist()
			local exprList, exprCommaList = {}, {}
			local eqToken;
			if peek().Source == '=' then
				eqToken = get()
				exprList, exprCommaList = exprlist()
			end
			return MkNode{
				Type = 'LocalVarStat';
				VarList = varList;
				ExprList = exprList;
				Token_Local = localKw;
				Token_Equals = eqToken;
				Token_VarCommaList = varCommaList;
				Token_ExprCommaList = exprCommaList;	
				GetFirstToken = function(self)
					return self.Token_Local
				end;
				GetLastToken = function(self)
					if #self.ExprList > 0 then
						return self.ExprList[#self.ExprList]:GetLastToken()
					else
						return self.VarList[#self.VarList]
					end
				end;
			}
		else
			error("`function` or ident expected")
		end
	end

	-- Return statement
	local function retstat()
		local returnKw = get()
		local exprList;
		local commaList;
		if isBlockFollow() or peek().Source == ';' then
			exprList = {}
			commaList = {}
		else
			exprList, commaList = exprlist()
		end
		return {
			Type = 'ReturnStat';
			ExprList = exprList;
			Token_Return = returnKw;
			Token_CommaList = commaList;
			GetFirstToken = function(self)
				return self.Token_Return
			end;
			GetLastToken = function(self)
				if #self.ExprList > 0 then
					return self.ExprList[#self.ExprList]:GetLastToken()
				else
					return self.Token_Return
				end
			end;
		}
	end

	-- Break statement
	local function breakstat()
		local breakKw = get()
		return {
			Type = 'BreakStat';
			Token_Break = breakKw;
			GetFirstToken = function(self)
				return self.Token_Break
			end;
			GetLastToken = function(self)
				return self.Token_Break
			end;
		}
	end

	-- Expression
	local function statement()
		local tok = peek()
		if tok.Source == 'if' then
			return false, ifstat()
		elseif tok.Source == 'while' then
			return false, whilestat()
		elseif tok.Source == 'do' then
			return false, dostat()
		elseif tok.Source == 'for' then
			return false, forstat()
		elseif tok.Source == 'repeat' then
			return false, repeatstat()
		elseif tok.Source == 'function' then
			return false, funcdecl(false)
		elseif tok.Source == 'local' then
			return false, localdecl()
		elseif tok.Source == 'return' then
			return true, retstat()
		elseif tok.Source == 'break' then
			return true, breakstat()
		else
			return false, exprstat()
		end
	end

	-- Chunk
	block = function()
		local statements = {}
		local semicolons = {}
		local isLast = false
		while not isLast and not isBlockFollow() do
			-- Parse statement
			local stat;
			isLast, stat = statement()
			table.insert(statements, stat)
			local next = peek()
			if next.Type == 'Symbol' and next.Source == ';' then
				semicolons[#statements] = get()
			end
		end
		return {
			Type = 'StatList';
			StatementList = statements;
			SemicolonList = semicolons;
			GetFirstToken = function(self)
				if #self.StatementList == 0 then
					return nil
				else
					return self.StatementList[1]:GetFirstToken()
				end
			end;
			GetLastToken = function(self)
				if #self.StatementList == 0 then
					return nil
				elseif self.SemicolonList[#self.StatementList] then
					-- Last token may be one of the semicolon separators
					return self.SemicolonList[#self.StatementList]
				else
					return self.StatementList[#self.StatementList]:GetLastToken()
				end
			end;
		}
	end

	return block()
end

function VisitAst(ast, visitors)
	local ExprType = lookupify{
		'BinopExpr'; 'UnopExpr'; 
		'NumberLiteral'; 'StringLiteral'; 'NilLiteral'; 'BooleanLiteral'; 'VargLiteral';
		'FieldExpr'; 'IndexExpr';
		'MethodExpr'; 'CallExpr';
		'FunctionLiteral';
		'VariableExpr';
		'ParenExpr';
		'TableLiteral';
	}

	local StatType = lookupify{
		'StatList';
		'BreakStat';
		'ReturnStat';
		'LocalVarStat';
		'LocalFunctionStat';
		'FunctionStat';
		'RepeatStat';
		'GenericForStat';
		'NumericForStat';
		'WhileStat';
		'DoStat';
		'IfStat';
		'CallExprStat';
		'AssignmentStat';
	}

	-- Check for typos in visitor construction
	for visitorSubject, visitor in pairs(visitors) do
		if not StatType[visitorSubject] and not ExprType[visitorSubject] then
			error("Invalid visitor target: `"..visitorSubject.."`")
		end
	end

	-- Helpers to call visitors on a node
	local function preVisit(exprOrStat)
		local visitor = visitors[exprOrStat.Type]
		if type(visitor) == 'function' then
			return visitor(exprOrStat)
		elseif visitor and visitor.Pre then
			return visitor.Pre(exprOrStat)
		end
	end
	local function postVisit(exprOrStat)
		local visitor = visitors[exprOrStat.Type]
		if visitor and type(visitor) == 'table' and visitor.Post then
			return visitor.Post(exprOrStat)
		end
	end

	local visitExpr, visitStat;

	visitExpr = function(expr)
		if preVisit(expr) then
			-- Handler did custom child iteration or blocked child iteration
			return
		end
		if expr.Type == 'BinopExpr' then
			visitExpr(expr.Lhs)
			visitExpr(expr.Rhs)
		elseif expr.Type == 'UnopExpr' then
			visitExpr(expr.Rhs)
		elseif expr.Type == 'NumberLiteral' or expr.Type == 'StringLiteral' or 
			expr.Type == 'NilLiteral' or expr.Type == 'BooleanLiteral' or 
			expr.Type == 'VargLiteral' 
		then
			-- No children to visit, single token literals
		elseif expr.Type == 'FieldExpr' then
			visitExpr(expr.Base)
		elseif expr.Type == 'IndexExpr' then
			visitExpr(expr.Base)
			visitExpr(expr.Index)
		elseif expr.Type == 'MethodExpr' or expr.Type == 'CallExpr' then
			visitExpr(expr.Base)
			if expr.FunctionArguments.CallType == 'ArgCall' then
				for index, argExpr in pairs(expr.FunctionArguments.ArgList) do
					visitExpr(argExpr)
				end
			elseif expr.FunctionArguments.CallType == 'TableCall' then
				visitExpr(expr.FunctionArguments.TableExpr)
			end
		elseif expr.Type == 'FunctionLiteral' then
			visitStat(expr.Body)
		elseif expr.Type == 'VariableExpr' then
			-- No children to visit
		elseif expr.Type == 'ParenExpr' then
			visitExpr(expr.Expression)
		elseif expr.Type == 'TableLiteral' then
			for index, entry in pairs(expr.EntryList) do
				if entry.EntryType == 'Field' then
					visitExpr(entry.Value)
				elseif entry.EntryType == 'Index' then
					visitExpr(entry.Index)
					visitExpr(entry.Value)
				elseif entry.EntryType == 'Value' then
					visitExpr(entry.Value)
				else
					assert(false, "unreachable")
				end
			end
		else
			assert(false, "unreachable, type: "..expr.Type..":"..FormatTable(expr))
		end
		postVisit(expr)
	end

	visitStat = function(stat)
		if preVisit(stat) then
			-- Handler did custom child iteration or blocked child iteration
			return
		end
		if stat.Type == 'StatList' then
			for index, ch in pairs(stat.StatementList) do
				visitStat(ch)
			end
		elseif stat.Type == 'BreakStat' then
			-- No children to visit
		elseif stat.Type == 'ReturnStat' then
			for index, expr in pairs(stat.ExprList) do
				visitExpr(expr)
			end
		elseif stat.Type == 'LocalVarStat' then
			if stat.Token_Equals then
				for index, expr in pairs(stat.ExprList) do
					visitExpr(expr)
				end
			end
		elseif stat.Type == 'LocalFunctionStat' then
			visitStat(stat.FunctionStat.Body)
		elseif stat.Type == 'FunctionStat' then
			visitStat(stat.Body)
		elseif stat.Type == 'RepeatStat' then
			visitStat(stat.Body)
			visitExpr(stat.Condition)
		elseif stat.Type == 'GenericForStat' then
			for index, expr in pairs(stat.GeneratorList) do
				visitExpr(expr)
			end
			visitStat(stat.Body)
		elseif stat.Type == 'NumericForStat' then
			for index, expr in pairs(stat.RangeList) do
				visitExpr(expr)
			end
			visitStat(stat.Body)
		elseif stat.Type == 'WhileStat' then
			visitExpr(stat.Condition)
			visitStat(stat.Body)
		elseif stat.Type == 'DoStat' then
			visitStat(stat.Body)
		elseif stat.Type == 'IfStat' then
			visitExpr(stat.Condition)
			visitStat(stat.Body)
			for _, clause in pairs(stat.ElseClauseList) do
				if clause.Condition then
					visitExpr(clause.Condition)
				end
				visitStat(clause.Body)
			end
		elseif stat.Type == 'CallExprStat' then
			visitExpr(stat.Expression)
		elseif stat.Type == 'AssignmentStat' then
			for index, ex in pairs(stat.Lhs) do
				visitExpr(ex)
			end
			for index, ex in pairs(stat.Rhs) do
				visitExpr(ex)
			end
		else
			assert(false, "unreachable")
		end	
		postVisit(stat)
	end

	if StatType[ast.Type] then
		visitStat(ast)
	else
		visitExpr(ast)
	end
end

function AddVariableInfo(ast)
	local globalVars = {}
	local currentScope = nil

	-- Numbering generator for variable lifetimes
	local locationGenerator = 0
	local function markLocation()
		locationGenerator = locationGenerator + 1
		return locationGenerator
	end

	-- Scope management
	local function pushScope()
		currentScope = {
			ParentScope = currentScope;
			ChildScopeList = {};
			VariableList = {};
			BeginLocation = markLocation();
		}
		if currentScope.ParentScope then
			currentScope.Depth = currentScope.ParentScope.Depth + 1
			table.insert(currentScope.ParentScope.ChildScopeList, currentScope)
		else
			currentScope.Depth = 1
		end
		function currentScope:GetVar(varName)
			for _, var in pairs(self.VariableList) do
				if var.Name == varName then
					return var
				end
			end
			if self.ParentScope then
				return self.ParentScope:GetVar(varName)
			else
				for _, var in pairs(globalVars) do
					if var.Name == varName then
						return var
					end
				end
			end
		end
	end
	local function popScope()
		local scope = currentScope

		-- Mark where this scope ends
		scope.EndLocation = markLocation()

		-- Mark all of the variables in the scope as ending there
		for _, var in pairs(scope.VariableList) do
			var.ScopeEndLocation = scope.EndLocation
		end

		-- Move to the parent scope
		currentScope = scope.ParentScope

		return scope
	end
	pushScope() -- push initial scope

	-- Add / reference variables
	local function addLocalVar(name, setNameFunc, localInfo)
		assert(localInfo, "Misisng localInfo")
		assert(name, "Missing local var name")
		local var = {
			Type = 'Local';
			Name = name;
			RenameList = {setNameFunc};
			AssignedTo = false;
			Info = localInfo;
			UseCount = 0;
			Scope = currentScope;
			BeginLocation = markLocation();
			EndLocation = markLocation();
			ReferenceLocationList = {markLocation()};
		}
		function var:Rename(newName)
			self.Name = newName
			for _, renameFunc in pairs(self.RenameList) do
				renameFunc(newName)
			end
		end
		function var:Reference()
			self.UseCount = self.UseCount + 1
		end
		table.insert(currentScope.VariableList, var)
		return var
	end
	local function getGlobalVar(name)
		for _, var in pairs(globalVars) do
			if var.Name == name then
				return var
			end
		end
		local var = {
			Type = 'Global';
			Name = name;
			RenameList = {};
			AssignedTo = false;
			UseCount = 0;
			Scope = nil; -- Globals have no scope
			BeginLocation = markLocation();
			EndLocation = markLocation();
			ReferenceLocationList = {};
		}
		function var:Rename(newName)
			self.Name = newName
			for _, renameFunc in pairs(self.RenameList) do
				renameFunc(newName)
			end
		end
		function var:Reference()
			self.UseCount = self.UseCount + 1
		end
		table.insert(globalVars, var)
		return var
	end
	local function addGlobalReference(name, setNameFunc)
		assert(name, "Missing var name")
		local var = getGlobalVar(name)
		table.insert(var.RenameList, setNameFunc)
		return var
	end
	local function getLocalVar(scope, name)
		-- First search this scope
		-- Note: Reverse iterate here because Lua does allow shadowing a local
		--       within the same scope, and the later defined variable should
		--       be the one referenced.
		for i = #scope.VariableList, 1, -1 do
			if scope.VariableList[i].Name == name then
				return scope.VariableList[i]
			end
		end

		-- Then search parent scope
		if scope.ParentScope then
			local var = getLocalVar(scope.ParentScope, name)
			if var then
				return var
			end
		end

		-- Then 
		return nil
	end
	local function referenceVariable(name, setNameFunc)
		assert(name, "Missing var name")
		local var = getLocalVar(currentScope, name)
		if var then
			table.insert(var.RenameList, setNameFunc)
		else
			var = addGlobalReference(name, setNameFunc)
		end
		-- Update the end location of where this variable is used, and
		-- add this location to the list of references to this variable.
		local curLocation = markLocation()
		var.EndLocation = curLocation
		table.insert(var.ReferenceLocationList, var.EndLocation)
		return var
	end

	local visitor = {}
	visitor.FunctionLiteral = {
		-- Function literal adds a new scope and adds the function literal arguments
		-- as local variables in the scope.
		Pre = function(expr)
			pushScope()
			for index, ident in pairs(expr.ArgList) do
				local var = addLocalVar(ident.Source, function(name)
					ident.Source = name
				end, {
					Type = 'Argument';
					Index = index;
				})
			end
		end;
		Post = function(expr)
			popScope()
		end;
	}
	visitor.VariableExpr = function(expr)
		-- Variable expression references from existing local varibales
		-- in the current scope, annotating the variable usage with variable
		-- information.
		expr.Variable = referenceVariable(expr.Token.Source, function(newName)
			expr.Token.Source = newName
		end)
	end
	visitor.StatList = {
		-- StatList adds a new scope
		Pre = function(stat)
			pushScope()
		end;
		Post = function(stat)
			popScope()
		end;
	}
	visitor.LocalVarStat = {
		Post = function(stat)
			-- Local var stat adds the local variables to the current scope as locals
			-- We need to visit the subexpressions first, because these new locals
			-- will not be in scope for the initialization value expressions. That is:
			--  `local bar = bar + 1`
			-- Is valid code
			for varNum, ident in pairs(stat.VarList) do
				addLocalVar(ident.Source, function(name)
					stat.VarList[varNum].Source = name
				end, {
					Type = 'Local';
				})
			end		
		end;
	}
	visitor.LocalFunctionStat = {
		Pre = function(stat)
			-- Local function stat adds the function itself to the current scope as
			-- a local variable, and creates a new scope with the function arguments
			-- as local variables.
			addLocalVar(stat.FunctionStat.NameChain[1].Source, function(name)
				stat.FunctionStat.NameChain[1].Source = name
			end, {
				Type = 'LocalFunction';
			})
			pushScope()
			for index, ident in pairs(stat.FunctionStat.ArgList) do
				addLocalVar(ident.Source, function(name)
					ident.Source = name
				end, {
					Type = 'Argument';
					Index = index;
				})
			end
		end;
		Post = function()
			popScope()
		end;
	}
	visitor.FunctionStat = {
		Pre = function(stat) 			
			-- Function stat adds a new scope containing the function arguments
			-- as local variables.
			-- A function stat may also assign to a global variable if it is in
			-- the form `function foo()` with no additional dots/colons in the 
			-- name chain.
			local nameChain = stat.NameChain
			local var;
			if #nameChain == 1 then
				-- If there is only one item in the name chain, then the first item
				-- is a reference to a global variable.
				var = addGlobalReference(nameChain[1].Source, function(name)
					nameChain[1].Source = name
				end)
			else
				var = referenceVariable(nameChain[1].Source, function(name)
					nameChain[1].Source = name
				end)
			end
			var.AssignedTo = true
			pushScope()
			for index, ident in pairs(stat.ArgList) do
				addLocalVar(ident.Source, function(name)
					ident.Source = name
				end, {
					Type = 'Argument';
					Index = index;
				})
			end
		end;
		Post = function()
			popScope()
		end;
	}
	visitor.GenericForStat = {
		Pre = function(stat)
			-- Generic fors need an extra scope holding the range variables
			-- Need a custom visitor so that the generator expressions can be
			-- visited before we push a scope, but the body can be visited
			-- after we push a scope.
			for _, ex in pairs(stat.GeneratorList) do
				VisitAst(ex, visitor)
			end
			pushScope()
			for index, ident in pairs(stat.VarList) do
				addLocalVar(ident.Source, function(name)
					ident.Source = name
				end, {
					Type = 'ForRange';
					Index = index;
				})
			end
			VisitAst(stat.Body, visitor)
			popScope()
			return true -- Custom visit
		end;
	}
	visitor.NumericForStat = {
		Pre = function(stat)
			-- Numeric fors need an extra scope holding the range variables
			-- Need a custom visitor so that the generator expressions can be
			-- visited before we push a scope, but the body can be visited
			-- after we push a scope.
			for _, ex in pairs(stat.RangeList) do
				VisitAst(ex, visitor)
			end
			pushScope()
			for index, ident in pairs(stat.VarList) do
				addLocalVar(ident.Source, function(name)
					ident.Source = name
				end, {
					Type = 'ForRange';
					Index = index;
				})
			end
			VisitAst(stat.Body, visitor)
			popScope()
			return true	-- Custom visit
		end;
	}
	visitor.AssignmentStat = {
		Post = function(stat)
			-- For an assignment statement we need to mark the
			-- "assigned to" flag on variables.
			for _, ex in pairs(stat.Lhs) do
				if ex.Variable then
					ex.Variable.AssignedTo = true
				end
			end
		end;
	}

	VisitAst(ast, visitor)

	return globalVars, popScope()
end

-- Prints out an AST to a string
function PrintAst(ast)

	local printStat, printExpr, ret;

	ret = ""

	local function printt(tk)
		if not tk.LeadingWhite or not tk.Source then
			error("Bad token: "..FormatTable(tk))
		end
		ret=ret..tk.LeadingWhite
		ret=ret..tk.Source
	end

	printExpr = function(expr)
		if expr.Type == 'BinopExpr' then
			printExpr(expr.Lhs)
			printt(expr.Token_Op)
			printExpr(expr.Rhs)
		elseif expr.Type == 'UnopExpr' then
			printt(expr.Token_Op)
			printExpr(expr.Rhs)
		elseif expr.Type == 'NumberLiteral' or expr.Type == 'StringLiteral' or 
			expr.Type == 'NilLiteral' or expr.Type == 'BooleanLiteral' or 
			expr.Type == 'VargLiteral' 
		then
			-- Just print the token
			printt(expr.Token)
		elseif expr.Type == 'FieldExpr' then
			printExpr(expr.Base)
			printt(expr.Token_Dot)
			printt(expr.Field)
		elseif expr.Type == 'IndexExpr' then
			printExpr(expr.Base)
			printt(expr.Token_OpenBracket)
			printExpr(expr.Index)
			printt(expr.Token_CloseBracket)
		elseif expr.Type == 'MethodExpr' or expr.Type == 'CallExpr' then
			printExpr(expr.Base)
			if expr.Type == 'MethodExpr' then
				printt(expr.Token_Colon)
				printt(expr.Method)
			end
			if expr.FunctionArguments.CallType == 'StringCall' then
				printt(expr.FunctionArguments.Token)
			elseif expr.FunctionArguments.CallType == 'ArgCall' then
				printt(expr.FunctionArguments.Token_OpenParen)
				for index, argExpr in pairs(expr.FunctionArguments.ArgList) do
					printExpr(argExpr)
					local sep = expr.FunctionArguments.Token_CommaList[index]
					if sep then
						printt(sep)
					end
				end
				printt(expr.FunctionArguments.Token_CloseParen)
			elseif expr.FunctionArguments.CallType == 'TableCall' then
				printExpr(expr.FunctionArguments.TableExpr)
			end
		elseif expr.Type == 'FunctionLiteral' then
			printt(expr.Token_Function)
			printt(expr.Token_OpenParen)
			for index, arg in pairs(expr.ArgList) do
				printt(arg)
				local comma = expr.Token_ArgCommaList[index]
				if comma then
					printt(comma)
				end
			end
			printt(expr.Token_CloseParen)
			printStat(expr.Body)
			printt(expr.Token_End)
		elseif expr.Type == 'VariableExpr' then
			printt(expr.Token)
		elseif expr.Type == 'ParenExpr' then
			printt(expr.Token_OpenParen)
			printExpr(expr.Expression)
			printt(expr.Token_CloseParen)
		elseif expr.Type == 'TableLiteral' then
			printt(expr.Token_OpenBrace)
			for index, entry in pairs(expr.EntryList) do
				if entry.EntryType == 'Field' then
					printt(entry.Field)
					printt(entry.Token_Equals)
					printExpr(entry.Value)
				elseif entry.EntryType == 'Index' then
					printt(entry.Token_OpenBracket)
					printExpr(entry.Index)
					printt(entry.Token_CloseBracket)
					printt(entry.Token_Equals)
					printExpr(entry.Value)
				elseif entry.EntryType == 'Value' then
					printExpr(entry.Value)
				else
					assert(false, "unreachable")
				end
				local sep = expr.Token_SeparatorList[index]
				if sep then
					printt(sep)
				end
			end
			printt(expr.Token_CloseBrace)
		else
			assert(false, "unreachable, type: "..expr.Type..":"..FormatTable(expr))
		end
	end

	printStat = function(stat)
		if stat.Type == 'StatList' then
			for index, ch in pairs(stat.StatementList) do
				printStat(ch)
				if stat.SemicolonList[index] then
					printt(stat.SemicolonList[index])
				end
			end
		elseif stat.Type == 'BreakStat' then
			printt(stat.Token_Break)
		elseif stat.Type == 'ReturnStat' then
			printt(stat.Token_Return)
			for index, expr in pairs(stat.ExprList) do
				printExpr(expr)
				if stat.Token_CommaList[index] then
					printt(stat.Token_CommaList[index])
				end
			end
		elseif stat.Type == 'LocalVarStat' then
			printt(stat.Token_Local)
			for index, var in pairs(stat.VarList) do
				printt(var)
				local comma = stat.Token_VarCommaList[index]
				if comma then
					printt(comma)
				end
			end
			if stat.Token_Equals then
				printt(stat.Token_Equals)
				for index, expr in pairs(stat.ExprList) do
					printExpr(expr)
					local comma = stat.Token_ExprCommaList[index]
					if comma then
						printt(comma)
					end
				end
			end
		elseif stat.Type == 'LocalFunctionStat' then
			printt(stat.Token_Local)
			printt(stat.FunctionStat.Token_Function)
			printt(stat.FunctionStat.NameChain[1])
			printt(stat.FunctionStat.Token_OpenParen)
			for index, arg in pairs(stat.FunctionStat.ArgList) do
				printt(arg)
				local comma = stat.FunctionStat.Token_ArgCommaList[index]
				if comma then
					printt(comma)
				end
			end
			printt(stat.FunctionStat.Token_CloseParen)
			printStat(stat.FunctionStat.Body)
			printt(stat.FunctionStat.Token_End)
		elseif stat.Type == 'FunctionStat' then
			printt(stat.Token_Function)
			for index, part in pairs(stat.NameChain) do
				printt(part)
				local sep = stat.Token_NameChainSeparator[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_OpenParen)
			for index, arg in pairs(stat.ArgList) do
				printt(arg)
				local comma = stat.Token_ArgCommaList[index]
				if comma then
					printt(comma)
				end
			end
			printt(stat.Token_CloseParen)
			printStat(stat.Body)
			printt(stat.Token_End)
		elseif stat.Type == 'RepeatStat' then
			printt(stat.Token_Repeat)
			printStat(stat.Body)
			printt(stat.Token_Until)
			printExpr(stat.Condition)
		elseif stat.Type == 'GenericForStat' then
			printt(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				printt(var)
				local sep = stat.Token_VarCommaList[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_In)
			for index, expr in pairs(stat.GeneratorList) do
				printExpr(expr)
				local sep = stat.Token_GeneratorCommaList[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_Do)
			printStat(stat.Body)
			printt(stat.Token_End)
		elseif stat.Type == 'NumericForStat' then
			printt(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				printt(var)
				local sep = stat.Token_VarCommaList[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_Equals)
			for index, expr in pairs(stat.RangeList) do
				printExpr(expr)
				local sep = stat.Token_RangeCommaList[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_Do)
			printStat(stat.Body)
			printt(stat.Token_End)		
		elseif stat.Type == 'WhileStat' then
			printt(stat.Token_While)
			printExpr(stat.Condition)
			printt(stat.Token_Do)
			printStat(stat.Body)
			printt(stat.Token_End)
		elseif stat.Type == 'DoStat' then
			printt(stat.Token_Do)
			printStat(stat.Body)
			printt(stat.Token_End)
		elseif stat.Type == 'IfStat' then
			printt(stat.Token_If)
			printExpr(stat.Condition)
			printt(stat.Token_Then)
			printStat(stat.Body)
			for _, clause in pairs(stat.ElseClauseList) do
				printt(clause.Token)
				if clause.Condition then
					printExpr(clause.Condition)
					printt(clause.Token_Then)
				end
				printStat(clause.Body)
			end
			printt(stat.Token_End)
		elseif stat.Type == 'CallExprStat' then
			printExpr(stat.Expression)
		elseif stat.Type == 'AssignmentStat' then
			for index, ex in pairs(stat.Lhs) do
				printExpr(ex)
				local sep = stat.Token_LhsSeparatorList[index]
				if sep then
					printt(sep)
				end
			end
			printt(stat.Token_Equals)
			for index, ex in pairs(stat.Rhs) do
				printExpr(ex)
				local sep = stat.Token_RhsSeparatorList[index]
				if sep then
					printt(sep)
				end
			end
		else
			assert(false, "unreachable")
		end	
	end

	printStat(ast)
	return ret
end

-- Adds / removes whitespace in an AST to put it into a "standard formatting"
local function FormatAst(ast)
	local formatStat, formatExpr;

	local currentIndent = 0

	local function applyIndent(token)
		local indentString = '\n'..('\t'):rep(currentIndent)
		if token.LeadingWhite == '' or (token.LeadingWhite:sub(-#indentString, -1) ~= indentString) then
			-- Trim existing trailing whitespace on LeadingWhite
			-- Trim trailing tabs and spaces, and up to one newline
			token.LeadingWhite = token.LeadingWhite:gsub("\n?[\t ]*$", "")
			token.LeadingWhite = token.LeadingWhite..indentString
		end
	end

	local function indent()
		currentIndent = currentIndent + 1
	end

	local function undent()
		currentIndent = currentIndent - 1
		assert(currentIndent >= 0, "Undented too far")
	end

	local function leadingChar(tk)
		if #tk.LeadingWhite > 0 then
			return tk.LeadingWhite:sub(1,1)
		else
			return tk.Source:sub(1,1)
		end
	end

	local function padToken(tk)
		if not WhiteChars[leadingChar(tk)] then
			tk.LeadingWhite = ' '..tk.LeadingWhite
		end
	end

	local function padExpr(expr)
		padToken(expr:GetFirstToken())
	end

	local function formatBody(openToken, bodyStat, closeToken)
		indent()
		formatStat(bodyStat)
		undent()
		applyIndent(closeToken)
	end

	formatExpr = function(expr)
		if expr.Type == 'BinopExpr' then
			formatExpr(expr.Lhs)
			formatExpr(expr.Rhs)
			if expr.Token_Op.Source == '..' then
				-- No padding on ..
			else
				padExpr(expr.Rhs)
				padToken(expr.Token_Op)
			end
		elseif expr.Type == 'UnopExpr' then
			formatExpr(expr.Rhs)
			--(expr.Token_Op)
		elseif expr.Type == 'NumberLiteral' or expr.Type == 'StringLiteral' or 
			expr.Type == 'NilLiteral' or expr.Type == 'BooleanLiteral' or 
			expr.Type == 'VargLiteral' 
		then
			-- Nothing to do
			--(expr.Token)
		elseif expr.Type == 'FieldExpr' then
			formatExpr(expr.Base)
			--(expr.Token_Dot)
			--(expr.Field)
		elseif expr.Type == 'IndexExpr' then
			formatExpr(expr.Base)
			formatExpr(expr.Index)
			--(expr.Token_OpenBracket)
			--(expr.Token_CloseBracket)
		elseif expr.Type == 'MethodExpr' or expr.Type == 'CallExpr' then
			formatExpr(expr.Base)
			if expr.Type == 'MethodExpr' then
				--(expr.Token_Colon)
				--(expr.Method)
			end
			if expr.FunctionArguments.CallType == 'StringCall' then
				--(expr.FunctionArguments.Token)
			elseif expr.FunctionArguments.CallType == 'ArgCall' then
				--(expr.FunctionArguments.Token_OpenParen)
				for index, argExpr in pairs(expr.FunctionArguments.ArgList) do
					formatExpr(argExpr)
					if index > 1 then
						padExpr(argExpr)
					end
					local sep = expr.FunctionArguments.Token_CommaList[index]
					if sep then
						--(sep)
					end
				end
				--(expr.FunctionArguments.Token_CloseParen)
			elseif expr.FunctionArguments.CallType == 'TableCall' then
				formatExpr(expr.FunctionArguments.TableExpr)
			end
		elseif expr.Type == 'FunctionLiteral' then
			--(expr.Token_Function)
			--(expr.Token_OpenParen)
			for index, arg in pairs(expr.ArgList) do
				--(arg)
				if index > 1 then
					padToken(arg)
				end
				local comma = expr.Token_ArgCommaList[index]
				if comma then
					--(comma)
				end
			end
			--(expr.Token_CloseParen)
			formatBody(expr.Token_CloseParen, expr.Body, expr.Token_End)
		elseif expr.Type == 'VariableExpr' then
			--(expr.Token)
		elseif expr.Type == 'ParenExpr' then
			formatExpr(expr.Expression)
			--(expr.Token_OpenParen)
			--(expr.Token_CloseParen)
		elseif expr.Type == 'TableLiteral' then
			--(expr.Token_OpenBrace)
			if #expr.EntryList == 0 then
				-- Nothing to do
			else
				indent()
				for index, entry in pairs(expr.EntryList) do
					if entry.EntryType == 'Field' then
						applyIndent(entry.Field)
						padToken(entry.Token_Equals)
						formatExpr(entry.Value)
						padExpr(entry.Value)
					elseif entry.EntryType == 'Index' then
						applyIndent(entry.Token_OpenBracket)
						formatExpr(entry.Index)
						--(entry.Token_CloseBracket)
						padToken(entry.Token_Equals)
						formatExpr(entry.Value)
						padExpr(entry.Value)
					elseif entry.EntryType == 'Value' then
						formatExpr(entry.Value)
						applyIndent(entry.Value:GetFirstToken())
					else
						assert(false, "unreachable")
					end
					local sep = expr.Token_SeparatorList[index]
					if sep then
						--(sep)
					end
				end
				undent()
				applyIndent(expr.Token_CloseBrace)
			end
			--(expr.Token_CloseBrace)
		else
			assert(false, "unreachable, type: "..expr.Type..":"..FormatTable(expr))
		end
	end

	formatStat = function(stat)
		if stat.Type == 'StatList' then
			for _, stat in pairs(stat.StatementList) do
				formatStat(stat)
				applyIndent(stat:GetFirstToken())
			end

		elseif stat.Type == 'BreakStat' then
			--(stat.Token_Break)

		elseif stat.Type == 'ReturnStat' then
			--(stat.Token_Return)
			for index, expr in pairs(stat.ExprList) do
				formatExpr(expr)
				padExpr(expr)
				if stat.Token_CommaList[index] then
					--(stat.Token_CommaList[index])
				end
			end
		elseif stat.Type == 'LocalVarStat' then
			--(stat.Token_Local)
			for index, var in pairs(stat.VarList) do
				padToken(var)
				local comma = stat.Token_VarCommaList[index]
				if comma then
					--(comma)
				end
			end
			if stat.Token_Equals then
				padToken(stat.Token_Equals)
				for index, expr in pairs(stat.ExprList) do
					formatExpr(expr)
					padExpr(expr)
					local comma = stat.Token_ExprCommaList[index]
					if comma then
						--(comma)
					end
				end
			end
		elseif stat.Type == 'LocalFunctionStat' then
			--(stat.Token_Local)
			padToken(stat.FunctionStat.Token_Function)
			padToken(stat.FunctionStat.NameChain[1])
			--(stat.FunctionStat.Token_OpenParen)
			for index, arg in pairs(stat.FunctionStat.ArgList) do
				if index > 1 then
					padToken(arg)
				end
				local comma = stat.FunctionStat.Token_ArgCommaList[index]
				if comma then
					--(comma)
				end
			end
			--(stat.FunctionStat.Token_CloseParen)
			formatBody(stat.FunctionStat.Token_CloseParen, stat.FunctionStat.Body, stat.FunctionStat.Token_End)
		elseif stat.Type == 'FunctionStat' then
			--(stat.Token_Function)
			for index, part in pairs(stat.NameChain) do
				if index == 1 then
					padToken(part)
				end
				local sep = stat.Token_NameChainSeparator[index]
				if sep then
					--(sep)
				end
			end
			--(stat.Token_OpenParen)
			for index, arg in pairs(stat.ArgList) do
				if index > 1 then
					padToken(arg)
				end
				local comma = stat.Token_ArgCommaList[index]
				if comma then
					--(comma)
				end
			end
			--(stat.Token_CloseParen)
			formatBody(stat.Token_CloseParen, stat.Body, stat.Token_End)
		elseif stat.Type == 'RepeatStat' then
			--(stat.Token_Repeat)
			formatBody(stat.Token_Repeat, stat.Body, stat.Token_Until)
			formatExpr(stat.Condition)
			padExpr(stat.Condition)
		elseif stat.Type == 'GenericForStat' then
			--(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				padToken(var)
				local sep = stat.Token_VarCommaList[index]
				if sep then
					--(sep)
				end
			end
			padToken(stat.Token_In)
			for index, expr in pairs(stat.GeneratorList) do
				formatExpr(expr)
				padExpr(expr)
				local sep = stat.Token_GeneratorCommaList[index]
				if sep then
					--(sep)
				end
			end
			padToken(stat.Token_Do)
			formatBody(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'NumericForStat' then
			--(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				padToken(var)
				local sep = stat.Token_VarCommaList[index]
				if sep then
					--(sep)
				end
			end
			padToken(stat.Token_Equals)
			for index, expr in pairs(stat.RangeList) do
				formatExpr(expr)
				padExpr(expr)
				local sep = stat.Token_RangeCommaList[index]
				if sep then
					--(sep)
				end
			end
			padToken(stat.Token_Do)
			formatBody(stat.Token_Do, stat.Body, stat.Token_End)	
		elseif stat.Type == 'WhileStat' then
			--(stat.Token_While)
			formatExpr(stat.Condition)
			padExpr(stat.Condition)
			padToken(stat.Token_Do)
			formatBody(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'DoStat' then
			--(stat.Token_Do)
			formatBody(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'IfStat' then
			--(stat.Token_If)
			formatExpr(stat.Condition)
			padExpr(stat.Condition)
			padToken(stat.Token_Then)
			--
			local lastBodyOpen = stat.Token_Then
			local lastBody = stat.Body
			--
			for _, clause in pairs(stat.ElseClauseList) do
				formatBody(lastBodyOpen, lastBody, clause.Token)
				lastBodyOpen = clause.Token
				--
				if clause.Condition then
					formatExpr(clause.Condition)
					padExpr(clause.Condition)
					padToken(clause.Token_Then)
					lastBodyOpen = clause.Token_Then
				end
				lastBody = clause.Body
			end
			--
			formatBody(lastBodyOpen, lastBody, stat.Token_End)

		elseif stat.Type == 'CallExprStat' then
			formatExpr(stat.Expression)
		elseif stat.Type == 'AssignmentStat' then
			for index, ex in pairs(stat.Lhs) do
				formatExpr(ex)
				if index > 1 then
					padExpr(ex)
				end
				local sep = stat.Token_LhsSeparatorList[index]
				if sep then
					--(sep)
				end
			end
			padToken(stat.Token_Equals)
			for index, ex in pairs(stat.Rhs) do
				formatExpr(ex)
				padExpr(ex)
				local sep = stat.Token_RhsSeparatorList[index]
				if sep then
					--(sep)
				end
			end
		else
			assert(false, "unreachable")
		end	
	end

	formatStat(ast)
end

-- Strips as much whitespace off of tokens in an AST as possible without causing problems
local function StripAst(ast)
	local stripStat, stripExpr;

	local function stript(token)
		token.LeadingWhite = ''
	end

	-- Make to adjacent tokens as close as possible
	local function joint(tokenA, tokenB)
		-- Strip the second token's whitespace
		stript(tokenB)

		-- Get the trailing A <-> leading B character pair
		local lastCh = tokenA.Source:sub(-1, -1)
		local firstCh = tokenB.Source:sub(1, 1)

		-- Cases to consider:
		--  Touching minus signs -> comment: `- -42` -> `--42' is invalid
		--  Touching words: `a b` -> `ab` is invalid
		--  Touching digits: `2 3`, can't occurr in the Lua syntax as number literals aren't a primary expression
		--  Abiguous syntax: `f(x)\n(x)()` is already disallowed, we can't cause a problem by removing newlines

		-- Figure out what separation is needed
		if 
			(lastCh == '-' and firstCh == '-') or
			(AllIdentChars[lastCh] and AllIdentChars[firstCh])
		then
			tokenB.LeadingWhite = ' ' -- Use a separator
		else
			tokenB.LeadingWhite = '' -- Don't use a separator
		end
	end

	-- Join up a statement body and it's opening / closing tokens
	local function bodyjoint(open, body, close)
		stripStat(body)
		stript(close)
		local bodyFirst = body:GetFirstToken()
		local bodyLast = body:GetLastToken()
		if bodyFirst then
			-- Body is non-empty, join body to open / close
			joint(open, bodyFirst)
			joint(bodyLast, close)
		else
			-- Body is empty, just join open and close token together
			joint(open, close)
		end
	end

	stripExpr = function(expr)
		if expr.Type == 'BinopExpr' then
			stripExpr(expr.Lhs)
			stript(expr.Token_Op)
			stripExpr(expr.Rhs)
			-- Handle the `a - -b` -/-> `a--b` case which would otherwise incorrectly generate a comment
			-- Also handles operators "or" / "and" which definitely need joining logic in a bunch of cases
			joint(expr.Token_Op, expr.Rhs:GetFirstToken())
			joint(expr.Lhs:GetLastToken(), expr.Token_Op)
		elseif expr.Type == 'UnopExpr' then
			stript(expr.Token_Op)
			stripExpr(expr.Rhs)
			-- Handle the `- -b` -/-> `--b` case which would otherwise incorrectly generate a comment
			joint(expr.Token_Op, expr.Rhs:GetFirstToken())
		elseif expr.Type == 'NumberLiteral' or expr.Type == 'StringLiteral' or 
			expr.Type == 'NilLiteral' or expr.Type == 'BooleanLiteral' or 
			expr.Type == 'VargLiteral' 
		then
			-- Just print the token
			stript(expr.Token)
		elseif expr.Type == 'FieldExpr' then
			stripExpr(expr.Base)
			stript(expr.Token_Dot)
			stript(expr.Field)
		elseif expr.Type == 'IndexExpr' then
			stripExpr(expr.Base)
			stript(expr.Token_OpenBracket)
			stripExpr(expr.Index)
			stript(expr.Token_CloseBracket)
		elseif expr.Type == 'MethodExpr' or expr.Type == 'CallExpr' then
			stripExpr(expr.Base)
			if expr.Type == 'MethodExpr' then
				stript(expr.Token_Colon)
				stript(expr.Method)
			end
			if expr.FunctionArguments.CallType == 'StringCall' then
				stript(expr.FunctionArguments.Token)
			elseif expr.FunctionArguments.CallType == 'ArgCall' then
				stript(expr.FunctionArguments.Token_OpenParen)
				for index, argExpr in pairs(expr.FunctionArguments.ArgList) do
					stripExpr(argExpr)
					local sep = expr.FunctionArguments.Token_CommaList[index]
					if sep then
						stript(sep)
					end
				end
				stript(expr.FunctionArguments.Token_CloseParen)
			elseif expr.FunctionArguments.CallType == 'TableCall' then
				stripExpr(expr.FunctionArguments.TableExpr)
			end
		elseif expr.Type == 'FunctionLiteral' then
			stript(expr.Token_Function)
			stript(expr.Token_OpenParen)
			for index, arg in pairs(expr.ArgList) do
				stript(arg)
				local comma = expr.Token_ArgCommaList[index]
				if comma then
					stript(comma)
				end
			end
			stript(expr.Token_CloseParen)
			bodyjoint(expr.Token_CloseParen, expr.Body, expr.Token_End)
		elseif expr.Type == 'VariableExpr' then
			stript(expr.Token)
		elseif expr.Type == 'ParenExpr' then
			stript(expr.Token_OpenParen)
			stripExpr(expr.Expression)
			stript(expr.Token_CloseParen)
		elseif expr.Type == 'TableLiteral' then
			stript(expr.Token_OpenBrace)
			for index, entry in pairs(expr.EntryList) do
				if entry.EntryType == 'Field' then
					stript(entry.Field)
					stript(entry.Token_Equals)
					stripExpr(entry.Value)
				elseif entry.EntryType == 'Index' then
					stript(entry.Token_OpenBracket)
					stripExpr(entry.Index)
					stript(entry.Token_CloseBracket)
					stript(entry.Token_Equals)
					stripExpr(entry.Value)
				elseif entry.EntryType == 'Value' then
					stripExpr(entry.Value)
				else
					assert(false, "unreachable")
				end
				local sep = expr.Token_SeparatorList[index]
				if sep then
					stript(sep)
				end
			end
			stript(expr.Token_CloseBrace)
		else
			assert(false, "unreachable, type: "..expr.Type..":"..FormatTable(expr))
		end
	end

	stripStat = function(stat)
		if stat.Type == 'StatList' then
			-- Strip all surrounding whitespace on statement lists along with separating whitespace
			for i = 1, #stat.StatementList do
				local chStat = stat.StatementList[i]

				-- Strip the statement and it's whitespace
				stripStat(chStat)
				stript(chStat:GetFirstToken())

				-- If there was a last statement, join them appropriately
				local lastChStat = stat.StatementList[i-1]
				if lastChStat then
					-- See if we can remove a semi-colon, the only case where we can't is if
					-- this and the last statement have a `);(` pair, where removing the semi-colon
					-- would introduce ambiguous syntax.
					if stat.SemicolonList[i-1] and 
						(lastChStat:GetLastToken().Source ~= ')' or chStat:GetFirstToken().Source ~= ')')
					then
						stat.SemicolonList[i-1] = nil
					end

					-- If there isn't a semi-colon, we should safely join the two statements
					-- (If there is one, then no whitespace leading chStat is always okay)
					if not stat.SemicolonList[i-1] then
						joint(lastChStat:GetLastToken(), chStat:GetFirstToken())
					end
				end
			end

			-- A semi-colon is never needed on the last stat in a statlist:
			stat.SemicolonList[#stat.StatementList] = nil

			-- The leading whitespace on the statlist should be stripped
			if #stat.StatementList > 0 then
				stript(stat.StatementList[1]:GetFirstToken())
			end

		elseif stat.Type == 'BreakStat' then
			stript(stat.Token_Break)

		elseif stat.Type == 'ReturnStat' then
			stript(stat.Token_Return)
			for index, expr in pairs(stat.ExprList) do
				stripExpr(expr)
				if stat.Token_CommaList[index] then
					stript(stat.Token_CommaList[index])
				end
			end
			if #stat.ExprList > 0 then
				joint(stat.Token_Return, stat.ExprList[1]:GetFirstToken())
			end
		elseif stat.Type == 'LocalVarStat' then
			stript(stat.Token_Local)
			for index, var in pairs(stat.VarList) do
				if index == 1 then
					joint(stat.Token_Local, var)
				else
					stript(var)
				end
				local comma = stat.Token_VarCommaList[index]
				if comma then
					stript(comma)
				end
			end
			if stat.Token_Equals then
				stript(stat.Token_Equals)
				for index, expr in pairs(stat.ExprList) do
					stripExpr(expr)
					local comma = stat.Token_ExprCommaList[index]
					if comma then
						stript(comma)
					end
				end
			end
		elseif stat.Type == 'LocalFunctionStat' then
			stript(stat.Token_Local)
			joint(stat.Token_Local, stat.FunctionStat.Token_Function)
			joint(stat.FunctionStat.Token_Function, stat.FunctionStat.NameChain[1])
			joint(stat.FunctionStat.NameChain[1], stat.FunctionStat.Token_OpenParen)
			for index, arg in pairs(stat.FunctionStat.ArgList) do
				stript(arg)
				local comma = stat.FunctionStat.Token_ArgCommaList[index]
				if comma then
					stript(comma)
				end
			end
			stript(stat.FunctionStat.Token_CloseParen)
			bodyjoint(stat.FunctionStat.Token_CloseParen, stat.FunctionStat.Body, stat.FunctionStat.Token_End)
		elseif stat.Type == 'FunctionStat' then
			stript(stat.Token_Function)
			for index, part in pairs(stat.NameChain) do
				if index == 1 then
					joint(stat.Token_Function, part)
				else
					stript(part)
				end
				local sep = stat.Token_NameChainSeparator[index]
				if sep then
					stript(sep)
				end
			end
			stript(stat.Token_OpenParen)
			for index, arg in pairs(stat.ArgList) do
				stript(arg)
				local comma = stat.Token_ArgCommaList[index]
				if comma then
					stript(comma)
				end
			end
			stript(stat.Token_CloseParen)
			bodyjoint(stat.Token_CloseParen, stat.Body, stat.Token_End)
		elseif stat.Type == 'RepeatStat' then
			stript(stat.Token_Repeat)
			bodyjoint(stat.Token_Repeat, stat.Body, stat.Token_Until)
			stripExpr(stat.Condition)
			joint(stat.Token_Until, stat.Condition:GetFirstToken())
		elseif stat.Type == 'GenericForStat' then
			stript(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				if index == 1 then
					joint(stat.Token_For, var)
				else
					stript(var)
				end
				local sep = stat.Token_VarCommaList[index]
				if sep then
					stript(sep)
				end
			end
			joint(stat.VarList[#stat.VarList], stat.Token_In)
			for index, expr in pairs(stat.GeneratorList) do
				stripExpr(expr)
				if index == 1 then
					joint(stat.Token_In, expr:GetFirstToken())
				end
				local sep = stat.Token_GeneratorCommaList[index]
				if sep then
					stript(sep)
				end
			end
			joint(stat.GeneratorList[#stat.GeneratorList]:GetLastToken(), stat.Token_Do)
			bodyjoint(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'NumericForStat' then
			stript(stat.Token_For)
			for index, var in pairs(stat.VarList) do
				if index == 1 then
					joint(stat.Token_For, var)
				else
					stript(var)
				end
				local sep = stat.Token_VarCommaList[index]
				if sep then
					stript(sep)
				end
			end
			joint(stat.VarList[#stat.VarList], stat.Token_Equals)
			for index, expr in pairs(stat.RangeList) do
				stripExpr(expr)
				if index == 1 then
					joint(stat.Token_Equals, expr:GetFirstToken())
				end
				local sep = stat.Token_RangeCommaList[index]
				if sep then
					stript(sep)
				end
			end
			joint(stat.RangeList[#stat.RangeList]:GetLastToken(), stat.Token_Do)
			bodyjoint(stat.Token_Do, stat.Body, stat.Token_End)	
		elseif stat.Type == 'WhileStat' then
			stript(stat.Token_While)
			stripExpr(stat.Condition)
			stript(stat.Token_Do)
			joint(stat.Token_While, stat.Condition:GetFirstToken())
			joint(stat.Condition:GetLastToken(), stat.Token_Do)
			bodyjoint(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'DoStat' then
			stript(stat.Token_Do)
			stript(stat.Token_End)
			bodyjoint(stat.Token_Do, stat.Body, stat.Token_End)
		elseif stat.Type == 'IfStat' then
			stript(stat.Token_If)
			stripExpr(stat.Condition)
			joint(stat.Token_If, stat.Condition:GetFirstToken())
			joint(stat.Condition:GetLastToken(), stat.Token_Then)
			--
			local lastBodyOpen = stat.Token_Then
			local lastBody = stat.Body
			--
			for _, clause in pairs(stat.ElseClauseList) do
				bodyjoint(lastBodyOpen, lastBody, clause.Token)
				lastBodyOpen = clause.Token
				--
				if clause.Condition then
					stripExpr(clause.Condition)
					joint(clause.Token, clause.Condition:GetFirstToken())
					joint(clause.Condition:GetLastToken(), clause.Token_Then)
					lastBodyOpen = clause.Token_Then
				end
				stripStat(clause.Body)
				lastBody = clause.Body
			end
			--
			bodyjoint(lastBodyOpen, lastBody, stat.Token_End)

		elseif stat.Type == 'CallExprStat' then
			stripExpr(stat.Expression)
		elseif stat.Type == 'AssignmentStat' then
			for index, ex in pairs(stat.Lhs) do
				stripExpr(ex)
				local sep = stat.Token_LhsSeparatorList[index]
				if sep then
					stript(sep)
				end
			end
			stript(stat.Token_Equals)
			for index, ex in pairs(stat.Rhs) do
				stripExpr(ex)
				local sep = stat.Token_RhsSeparatorList[index]
				if sep then
					stript(sep)
				end
			end
		else
			assert(false, "unreachable")
		end	
	end

	stripStat(ast)
end

local idGen = 0
local VarDigits = {}
for i = ('a'):byte(), ('z'):byte() do table.insert(VarDigits, string.char(i)) end
for i = ('A'):byte(), ('Z'):byte() do table.insert(VarDigits, string.char(i)) end
for i = ('0'):byte(), ('9'):byte() do table.insert(VarDigits, string.char(i)) end
table.insert(VarDigits, '_')
local VarStartDigits = {}
for i = ('a'):byte(), ('z'):byte() do table.insert(VarStartDigits, string.char(i)) end
for i = ('A'):byte(), ('Z'):byte() do table.insert(VarStartDigits, string.char(i)) end
local function indexToVarName(index)
	local id = ''
	local d = index % #VarStartDigits
	index = (index - d) / #VarStartDigits
	id = id..VarStartDigits[d+1]
	while index > 0 do
		local d = index % #VarDigits
		index = (index - d) / #VarDigits
		id = id..VarDigits[d+1]
	end
	return id
end
local function genNextVarName()
	local varToUse = idGen
	idGen = idGen + 1
	return indexToVarName(varToUse)
end
local function genVarName()
	local varName = ''
	repeat
		varName = genNextVarName()
	until not Keywords[varName]
	return varName
end
local function MinifyVariables(globalScope, rootScope, keepNames)
	keepNames = keepNames or {}
	-- externalGlobals is a set of global variables that have not been assigned to, that is
	-- global variables defined "externally to the script". We are not going to be renaming 
	-- those, and we have to make sure that we don't collide with them when renaming 
	-- things so we keep track of them in this set.
	local externalGlobals = {}

	-- First we want to rename all of the variables to unique temoraries, so that we can
	-- easily use the scope::GetVar function to check whether renames are valid.
	local temporaryIndex = 0
	for _, var in pairs(globalScope) do
		if var.AssignedTo and not keepNames[var.Name] then
			var:Rename('_TMP_'..temporaryIndex..'_')
			temporaryIndex = temporaryIndex + 1
		else
			-- Not assigned to, external global
			externalGlobals[var.Name] = true
		end
	end
	local function temporaryRename(scope)
		for _, var in pairs(scope.VariableList) do
			var:Rename('_TMP_'..temporaryIndex..'_')
			temporaryIndex = temporaryIndex + 1
		end
		for _, childScope in pairs(scope.ChildScopeList) do
			temporaryRename(childScope)
		end
	end

	-- Now we go through renaming, first do globals, we probably want them
	-- to have shorter names in general.
	-- TODO: Rename all vars based on frequency patterns, giving variables
	--       used more shorter names.
	local nextFreeNameIndex = 0
	for _, var in pairs(globalScope) do
		if var.AssignedTo and not externalGlobals[var.Name] then
			local varName = ''
			repeat
				varName = indexToVarName(nextFreeNameIndex)
				nextFreeNameIndex = nextFreeNameIndex + 1
			until not Keywords[varName] and not externalGlobals[varName]
			var:Rename(varName)
		end
	end

	-- Now rename all local vars
	rootScope.FirstFreeName = nextFreeNameIndex
	local function doRenameScope(scope)
		for _, var in pairs(scope.VariableList) do
			local varName = ''
			repeat
				varName = indexToVarName(scope.FirstFreeName)
				scope.FirstFreeName = scope.FirstFreeName + 1
			until not Keywords[varName] and not externalGlobals[varName]
			var:Rename(varName)
		end
		for _, childScope in pairs(scope.ChildScopeList) do
			childScope.FirstFreeName = scope.FirstFreeName
			doRenameScope(childScope)
		end
	end
	doRenameScope(rootScope)
end

local function MinifyVariables_2(globalScope, rootScope)
	-- Variable names and other names that are fixed, that we cannot use
	-- Either these are Lua keywords, or globals that are not assigned to,
	-- that is environmental globals that are assigned elsewhere beyond our 
	-- control.
	local globalUsedNames = {}
	for kw, _ in pairs(Keywords) do
		globalUsedNames[kw] = true
	end

	-- Gather a list of all of the variables that we will rename
	local allVariables = {}
	local allLocalVariables = {}
	do
		-- Add applicable globals
		for _, var in pairs(globalScope) do
			if var.AssignedTo then
				-- We can try to rename this global since it was assigned to
				-- (and thus presumably initialized) in the script we are 
				-- minifying.
				table.insert(allVariables, var)
			else
				-- We can't rename this global, mark it as an unusable name
				-- and don't add it to the nename list
				globalUsedNames[var.Name] = true
			end
		end

		-- Recursively add locals, we can rename all of those
		local function addFrom(scope)
			for _, var in pairs(scope.VariableList) do
				table.insert(allVariables, var)
				table.insert(allLocalVariables, var)
			end
			for _, childScope in pairs(scope.ChildScopeList) do
				addFrom(childScope)
			end
		end
		addFrom(rootScope)
	end

	-- Add used name arrays to variables
	for _, var in pairs(allVariables) do
		var.UsedNameArray = {}
	end

	-- Sort the least used variables first
	table.sort(allVariables, function(a, b)
		return #a.RenameList < #b.RenameList
	end)

	-- Lazy generator for valid names to rename to
	local nextValidNameIndex = 0
	local varNamesLazy = {}
	local function varIndexToValidVarName(i)
		local name = varNamesLazy[i] 
		if not name then
			repeat
				name = indexToVarName(nextValidNameIndex)
				nextValidNameIndex = nextValidNameIndex + 1
			until not globalUsedNames[name]
			varNamesLazy[i] = name
		end
		return name
	end

	-- For each variable, go to rename it
	for _, var in pairs(allVariables) do
		-- Lazy... todo: Make theis pair a proper for-each-pair-like set of loops 
		-- rather than using a renamed flag.
		var.Renamed = true

		-- Find the first unused name
		local i = 1
		while var.UsedNameArray[i] do
			i = i + 1
		end

		-- Rename the variable to that name
		var:Rename(varIndexToValidVarName(i))

		if var.Scope then
			-- Now we need to mark the name as unusable by any variables:
			--  1) At the same depth that overlap lifetime with this one
			--  2) At a deeper level, which have a reference to this variable in their lifetimes
			--  3) At a shallower level, which are referenced during this variable's lifetime
			for _, otherVar in pairs(allVariables) do
				if not otherVar.Renamed then
					if not otherVar.Scope or otherVar.Scope.Depth < var.Scope.Depth then
						-- Check Global variable (Which is always at a shallower level)
						--  or
						-- Check case 3
						-- The other var is at a shallower depth, is there a reference to it
						-- durring this variable's lifetime?
						for _, refAt in pairs(otherVar.ReferenceLocationList) do
							if refAt >= var.BeginLocation and refAt <= var.ScopeEndLocation then
								-- Collide
								otherVar.UsedNameArray[i] = true
								break
							end
						end

					elseif otherVar.Scope.Depth > var.Scope.Depth then
						-- Check Case 2
						-- The other var is at a greater depth, see if any of the references
						-- to this variable are in the other var's lifetime.
						for _, refAt in pairs(var.ReferenceLocationList) do
							if refAt >= otherVar.BeginLocation and refAt <= otherVar.ScopeEndLocation then
								-- Collide
								otherVar.UsedNameArray[i] = true
								break
							end
						end

					else --otherVar.Scope.Depth must be equal to var.Scope.Depth
						-- Check case 1
						-- The two locals are in the same scope
						-- Just check if the usage lifetimes overlap within that scope. That is, we
						-- can shadow a local variable within the same scope as long as the usages
						-- of the two locals do not overlap.
						if var.BeginLocation < otherVar.EndLocation and
							var.EndLocation > otherVar.BeginLocation
						then
							otherVar.UsedNameArray[i] = true
						end
					end
				end
			end
		else
			-- This is a global var, all other globals can't collide with it, and
			-- any local variable with a reference to this global in it's lifetime
			-- can't collide with it.
			for _, otherVar in pairs(allVariables) do
				if not otherVar.Renamed then
					if otherVar.Type == 'Global' then
						otherVar.UsedNameArray[i] = true
					elseif otherVar.Type == 'Local' then
						-- Other var is a local, see if there is a reference to this global within
						-- that local's lifetime.
						for _, refAt in pairs(var.ReferenceLocationList) do
							if refAt >= otherVar.BeginLocation and refAt <= otherVar.ScopeEndLocation then
								-- Collide
								otherVar.UsedNameArray[i] = true
								break
							end
						end
					else
						assert(false, "unreachable")
					end
				end
			end
		end
	end


	-- -- 
	-- print("Total Variables: "..#allVariables)
	-- print("Total Range: "..rootScope.BeginLocation.."-"..rootScope.EndLocation)
	-- print("")
	-- for _, var in pairs(allVariables) do
	-- 	io.write("`"..var.Name.."':\n\t#symbols: "..#var.RenameList..
	-- 		"\n\tassigned to: "..tostring(var.AssignedTo))
	-- 	if var.Type == 'Local' then
	-- 		io.write("\n\trange: "..var.BeginLocation.."-"..var.EndLocation)
	-- 		io.write("\n\tlocal type: "..var.Info.Type)
	-- 	end
	-- 	io.write("\n\n")
	-- end

	-- -- First we want to rename all of the variables to unique temoraries, so that we can
	-- -- easily use the scope::GetVar function to check whether renames are valid.
	-- local temporaryIndex = 0
	-- for _, var in pairs(allVariables) do
	-- 	var:Rename('_TMP_'..temporaryIndex..'_')
	-- 	temporaryIndex = temporaryIndex + 1
	-- end

	-- For each variable, we need to build a list of names that collide with it

	--
	--error()
end

local function BeautifyVariables(globalScope, rootScope, keepNames)
	keepNames = keepNames or {}
	local externalGlobals = {}
	for _, var in pairs(globalScope) do
		if (not var.AssignedTo) or (keepNames[var.Name]) then
			externalGlobals[var.Name] = true
		end
	end

	local localNumber = 1
	local globalNumber = 1

	local function setVarName(var, name)
		var.Name = name
		for _, setter in pairs(var.RenameList) do
			setter(name)
		end
	end

	for _, var in pairs(globalScope) do
		if var.AssignedTo then
			setVarName(var, 'G_'..globalNumber)
			globalNumber = globalNumber + 1
		end
	end

	local function modify(scope)
		for _, var in pairs(scope.VariableList) do
			local name = 'L_'..localNumber..'_'
			if var.Info.Type == 'Argument' then
				name = name..'arg'..var.Info.Index
			elseif var.Info.Type == 'LocalFunction' then
				name = name..'func'
			elseif var.Info.Type == 'ForRange' then
				name = name..'forvar'..var.Info.Index
			end
			setVarName(var, name)
			localNumber = localNumber + 1
		end
		for _, scope in pairs(scope.ChildScopeList) do
			modify(scope)
		end
	end
	modify(rootScope)
end

local function usageError()
	error(
			"\nusage: minify <file> or unminify <file>\n" ..
			"  The modified code will be printed to the stdout, pipe it to a file, the\n" ..
			"  lua interpreter, or something else as desired EG:\n\n" ..
			"        lua minify.lua minify input.lua > output.lua\n\n" ..
			"  * minify will minify the code in the file.\n" ..
			"  * unminify will beautify the code and replace the variable names with easily\n" ..
			"    find-replacable ones to aide in reverse engineering minified code.\n", 0)
end

local function _common(src,keepNames,minifying)
	local ast = CreateLuaParser(src)
	local global_scope, root_scope = AddVariableInfo(ast)
	if minifying then
		MinifyVariables(global_scope,root_scope,keepNames)
		StripAst(ast)
	else
		BeautifyVariables(global_scope,root_scope,keepNames)
		FormatAst(ast)
	end
	return PrintAst(ast)
end

local function minify(src,keepNames)
	return _common(src,keepNames,true)
end

local function beautify(src,keepNames)
	return _common(src,keepNames,false)
end

return {
	["minify"]=minify,
	["beautify"]=beautify
}

end,

["preprocessor"] = function()
--------------------
-- Module: 'preprocessor'
--------------------
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

end,

["utils"] = function()
--------------------
-- Module: 'utils'
--------------------
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

end,

----------------------
-- Modules part end --
----------------------
        }
        if files[path] then
            return files[path]
        else
            return origin_seacher(path)
        end
    end
end
---------------------------------------------------------
----------------Auto generated code block----------------
---------------------------------------------------------
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