
return function(import)
  local toBool = import("@Util/@Types/toBool")

  local function contains(arr, element)
    return toBool(table.find(arr, element))
  end

  return contains
end
