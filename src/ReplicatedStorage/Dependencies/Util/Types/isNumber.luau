
return function()
	local function isNumber(v)
		return type(v) == "number"
	end

	return isNumber
end
