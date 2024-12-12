
local function bothAreFunctions(a, b)
	local isFunction = require(script.Parent.isFunction)()
	
	return isFunction(a) and isFunction(b)
end

return bothAreFunctions
