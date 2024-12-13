
return function()
	local isIndexable = require(script.Parent.isIndexable)()
	
	local function bothAreIndexable(a, b)
		return isIndexable(a) and isIndexable(b)
	end

	return bothAreIndexable
end
