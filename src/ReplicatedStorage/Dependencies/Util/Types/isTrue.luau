
return function()
	local isBool = require(script.Parent.isBool)
	
	local function isTrue(v)
		return isBool(v) and v == true
	end

	return isTrue
end

