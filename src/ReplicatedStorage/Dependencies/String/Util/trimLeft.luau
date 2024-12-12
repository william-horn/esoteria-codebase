
return function()
	
	--[[
		@desc: Removes whitespace from the left of a string
		@params: <string> str
		@returns: <string> trimmedStr
	]]
	local function trimLeft(str)
		return str:gsub("^%s+", "")
	end
	
	return trimLeft
end