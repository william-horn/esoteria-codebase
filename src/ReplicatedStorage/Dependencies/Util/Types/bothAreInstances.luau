
return function(import)
	local isInstance = require(script.Parent.isInstance)()
	
	local function bothAreInstances(a, b)
		return isInstance(a) and isInstance(b)
	end

	return bothAreInstances
end