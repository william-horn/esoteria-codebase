
return function(import)
  local matchesQuery = import("@Table", "matchesQuery")

  local function queryMany(array, query, options)
    local matches = {} 

    for _, item in ipairs(array) do
      if matchesQuery(item, query, options) then
        table.insert(matches, item)
      end
    end

    return matches
  end

  return queryMany
end
