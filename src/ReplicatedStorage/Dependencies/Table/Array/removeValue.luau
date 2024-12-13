
return function()
  local function removeValue(arr, element)
    for i = 1, #arr do
      local v = arr[i]
      if (v == element) then
        return true, i
      end
    end

    return false, nil
  end

  return removeValue
end