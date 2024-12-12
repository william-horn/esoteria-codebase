
return function(import)
	local isTrue = require(script.Parent.Types.isTrue)()

	-- error handling
	local function assert(condition, err, default)
		if (not err) then return condition end

		if (isTrue(err) and condition) then
			error(default)
		elseif (condition) then
			error(err)
		end

		return condition
	end

	return assert
end