
return function()
	local isFunction = require(script.Parent.isFunction)()

	local function bothAreFunctions(a, b)
		return isFunction(a) and isFunction(b)
	end

	return bothAreFunctions
end
