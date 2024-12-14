
return function(import)
	local bothAreTables, isMatch = import("@Util", "@Types/bothAreTables", "isMatch")
	local size = import("@Table/size")

	--[[
		options:
		strictlyEquals<boolean>: Whether or not "data" and "query" should be exactly equal in content
		default: nil

		usePatterns<boolean>: Whether or not string values will compare using patterns in the query table
		default: nil

		caseSensitive<boolean>: Whether or not string values will ignore case sensitivity
		default: true
	]]

	local function matchesQuery(data, query, options)
		options = options or {}
		local queue = { {data, query} }

		while (#queue > 0) do
			local set = queue[#queue]

			local dataDir, queryDir = set[1], set[2]
			queue[#queue] = nil

			-- for strict equals case, keep track of query size:
			local querySize = 0

			-- check if all values in queryDir equal the respective values in dataDir
			for queryKey, queryVal in next, queryDir do
				querySize += 1
				local dataVal = dataDir[queryKey]

				if (dataVal == nil) then return false end

				if (bothAreTables(queryVal, dataVal)) then
					queue[#queue + 1] = { dataVal, queryVal }

				elseif (not isMatch(dataVal, queryVal, options)) then
					return false

				end
			end

			-- compare to see if both directories are an exact match using table size
			if (options.strictlyEquals and querySize ~= size(dataDir)) then
				return false
			end
		end

		return true
	end

	return matchesQuery
end
