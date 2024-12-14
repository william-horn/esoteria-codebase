--[[
	@author: William J. Horn
	@written: 12/14/2024

	Wrap a table in a new context that enables method calling through dot
	notation (i.e object.myMethod())

	? Works for momentary cases:

		local t = { name = "Will" }

		function t:getName()
			return self.name
		end

		print( withDotMethod(t).getName() ) --> "Will"

	? And for class-like structures:

		local Class = withDotMethod()
		Class.name = "Chuck"

		function Class:getName()
			return "class name: " .. self.name
		end

		print( Class.getName() ) --> "class name: Chuck"

	? Also works if calling the function after class creation:

		local Class = {}
		Class.name = "Josh"

		function Class:getName()
			return "Class name: " .. self.name
		end 

		Class = withDotMethod(Class)
		print( Class.getName() ) --> "class name: Josh"

	? Supports inheritance:

		local Class = {}
		Class.name = "Ralph"

		function Class:getName()
			return "class name: " .. self.name
		end

		function Class.new()
			return setmetatable({ name = "New Object" }, withDotMethod(Class))
		end

		local object = Class.new()
		print( object.getName() ) --> "New Object"

]]

return function()
	local function withDotMethod(o)
		o = o or {}

		local m = {}
		local _m = {}
		local f = {}
		
		local function repl(t, k, v)
			if (type(v) == "function") then
				if (f[t]) then
					f[t][k] = v
				else
					f[t] = { [k] = v }
				end
			elseif (f[t] and f[t][k]) then
				f[t][k] = v
			else
				rawset(t, k, v)
			end
		end
		
		for k, v in next, o do
			repl(m, k, v)
		end
		
		_m.__index = function(t, k)
			if (f[t] and f[t][k]) then
				return function(...)
					return f[t][k](t, ...)
				end
			elseif (f[m][k]) then
				return function(...)
					return f[m][k](t, ...)
				end
			else
				return nil
			end
		end
		
		_m.__newindex = repl
		
		return setmetatable(m, _m), _m
	end

	return withDotMethod
end
