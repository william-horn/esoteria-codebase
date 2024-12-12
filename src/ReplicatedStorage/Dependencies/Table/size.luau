
return function()
  --[[
    @desc: Returns the quantity of entries in a table
    @args: <table> dict
    @returns: <number> size
  ]]
  local function size(dict)
    local count = 0

    for k, v in next, dict do
      count = count + 1
    end

    return count
  end

  return size
end
