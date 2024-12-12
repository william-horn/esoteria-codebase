
return function()
	local function isTable(v)
		return type(v) == "table"
	end

	return isTable
end
