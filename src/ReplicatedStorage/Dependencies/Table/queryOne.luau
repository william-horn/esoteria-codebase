

return function(import)
  local matchesQuery = import("@Table", "matchesQuery")

  local function queryOne(array, query, options)
    for _, item in ipairs(array) do
      if matchesQuery(item, query, options) then
        return item
      end
    end

    return nil
  end

  return queryOne
end
