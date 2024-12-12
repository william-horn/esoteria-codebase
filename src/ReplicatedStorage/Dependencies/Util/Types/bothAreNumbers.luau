
return function()
	local isNumber = require(script.Parent.isNumber)()
	
	local function bothAreNumbers(a, b)
		return isNumber(a) and isNumber(b)
	end

	return bothAreNumbers
end
