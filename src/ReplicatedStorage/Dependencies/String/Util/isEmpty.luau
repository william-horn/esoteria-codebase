
return function()
	local removeWhitespace = require(script.Parent.removeWhitespace)
	
	--[[
		@desc: Checks if a string is empty or not
		@params: <string> str, <boolean> countSpaceCharAsEmpty (whether to count space chars as empty)
		@returns: <boolean> isEmpty
	]]
	local function isEmpty(str, countSpaceCharAsEmpty)
		return (countSpaceCharAsEmpty) and (removeWhitespace(str) == '') or (str == '')
	end
	
	return isEmpty
end