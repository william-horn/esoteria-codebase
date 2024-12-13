
return function()
  --[[
    @desc: Returns an array of all values in a table
    @args: <table> dict
    @returns: <array> values
  ]]
  local function values(dict)
    local arr = {}
  
    for k, v in next, dict do
      arr[#arr + 1] = v
    end
  
    return arr
  end

  return values
end
