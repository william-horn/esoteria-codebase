
return function()
  --[[
    @desc: Converts an array into a dictionary with the structure:
      array: {'a', 'b', 'c', ...}
      dict: {['a'] = 'a', ['b'] = 'b', ['c'] = 'c', ...}
    @args: <array> arr
    @returns: <dictionary> dict
  ]]
  local function toDict(arr)
    local dict = {}

    for i = 1, #arr do
      local v = arr[i]
      dict[v] = v
    end

    return dict
  end

  return toDict
end