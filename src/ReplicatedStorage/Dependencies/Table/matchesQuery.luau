
return function(import)
  local bothAreTables, isMatch = import("@Util", "@Types/bothAreTables", "isMatch")

  local function matchesQuery(data, query, options)
    local queue = { {data, query} }

    while (#queue > 0) do
      local dataDir, queryDir = unpack(queue[#queue])
      queue[#queue] = nil

      for queryKey, queryVal in next, queryDir do
        local dataVal = dataDir[queryKey]

        if (dataVal == nil) then return false end

        if (bothAreTables(queryVal, dataVal)) then
          queue[#queue + 1] = { dataVal, queryVal }

        elseif (not isMatch(dataVal, queryVal, options)) then
          return false

        end
      end
    end

    return true
  end

  return matchesQuery
end
