
return function(import)
  local toBool = import("@Util/@Types/toBool")

  local function contains(arr, element)
    return toBool(arr.find(element))
  end

  return contains
end