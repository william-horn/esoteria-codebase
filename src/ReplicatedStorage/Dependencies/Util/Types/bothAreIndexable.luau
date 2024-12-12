

local function bothAreIndexable(a, b)
	local isIndexable = require(script.Parent.isIndexable)()
	
	return isIndexable(a) and isIndexable(b)
end

return bothAreIndexable
