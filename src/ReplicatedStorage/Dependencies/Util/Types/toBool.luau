
return function()
  local function toBool(v)
    return not (not v)
  end
  
  return toBool
end