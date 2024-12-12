
return function()
  local function mergeArrays(arrays)
    local all = {}
  
    for i = 1, #arrays do
      local iv = arrays[i]
      for j = 1, #iv do
        local jv = iv[j]
        all[#all + 1] = jv
      end
    end
  
    return all
  end

  return mergeArrays
end