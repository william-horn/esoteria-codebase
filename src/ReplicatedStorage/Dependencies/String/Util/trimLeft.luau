
return function()
	
	--[[
		@desc: Removes whitespace from the left of a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function trimLeft(str)
		str = str:gsub("^%s+", "")
		return str
	end
	
	return trimLeft
end
