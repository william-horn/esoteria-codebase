
return function()
  local function isUserdata(v)
    return type(v) == "userdata"
  end

  return isUserdata
end
