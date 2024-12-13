
return function()
	local function reduce(t)
    local unique = {} 
    local seen = {} 
    
    for _, v in next, t do
        if not seen[v] then
            unique[#unique + 1] = v
            seen[v] = true 
        end
    end
    
    return unique
	end

	return reduce
end
