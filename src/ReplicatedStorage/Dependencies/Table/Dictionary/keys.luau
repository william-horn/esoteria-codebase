
return function()
  --[[
    @desc: Returns an array of all keys in a table
    @args: <table> dict
    @returns: <array> keys
  ]]
  local function keys(dict)
    local arr = {}

    for k, v in next, dict do
      arr[#arr + 1] = k
    end

    return arr
  end

  return keys
end
