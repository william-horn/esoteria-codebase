
return function()
	local function useDefaultOptions(inputTable, defaults)
		local output = table.clone(inputTable)
		
		for defaultKey, defaultVal in next, defaults do
			if (output[defaultKey] == nil) then
				output[defaultKey] = defaultVal
			end
		end
		
		return output
	end

  return useDefaultOptions
end