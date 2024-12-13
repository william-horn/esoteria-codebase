
return function()
	--[[
		? FYI:

		This was the former function that I have since replaced due to
		it being utterly useless. But, I was proud of the efficient solution
		so I'm keeping it here in case I ever need it.

		local t = {}

		local function trimBetween(str)
			return str:gsub("^(%s*)(.-)(%s*)$", function(sl, v, sr)
				t[1], t[2], t[3] = sl, v:gsub("(%s?)%s*", "%1"), sr
				local s = table.concat(t)
				t[1], t[2], t[3] = nil, nil, nil
				return s
			end)
		end

		-Will
	]]
	local function toSingleSpace(str)
		return str:gsub("%s+", " ")
	end
	
	return toSingleSpace
end
