
return function()
	local isString = require(script.Parent.isString)()
	
	local function bothAreStrings(a, b)
		return isString(a) and isString(b)
	end

	return bothAreStrings
end
