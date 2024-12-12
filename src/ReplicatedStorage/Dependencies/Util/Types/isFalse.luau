
return function()
	local isBool = require(script.Parent.isBool)()
	
	local function isFalse(v)
		return isBool(v) and v == false
	end

	return isFalse
end