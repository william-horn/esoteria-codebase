

return function(import)
  local isTable = import("@Util/@Types/isTable")

  local function isCustomType(v, typeName)
    if (isTable(v) and v._customType) then
    end
  end

  return isCustomType
end