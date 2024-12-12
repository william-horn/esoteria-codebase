
return function()
  --[[
    @desc: Merges two tables (dictionaries) into one
    @param <table> a
    @param <table> b
    @param <boolean> overwrite - If true, values from a will overwrite values in b
    @returns: <table> c
  ]]
  local function mergeDict(a, b, overwrite)
    local c = table.clone(b)

    for k, v in next, a do
      if (not c[k]) or overwrite then
        c[k] = v
      end
    end

    return c
  end

  return mergeDict
end