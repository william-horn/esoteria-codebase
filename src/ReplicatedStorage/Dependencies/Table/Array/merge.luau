
return function()
    --[[
    @desc: Merges two tables (arrays) into one
    @param <table> a
    @param <table> b
    @returns: <table> c
  ]]
  local function merge(a, b)
    local c = table.clone(b)

    for i = 1, #a do
      local v = a[i]
      c[#c + 1] = v
    end

    return c
  end

  return merge
end 