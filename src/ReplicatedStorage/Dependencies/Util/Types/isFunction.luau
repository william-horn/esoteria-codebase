
return function()
	local function isFunction(v)
		return type(v) == "function"
	end

	return isFunction
end