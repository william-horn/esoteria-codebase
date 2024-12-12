
return function()
  local function getBasePart()
    local part = Instance.new('Part')
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Anchored = true
    part.CanCollide = false

    return part
  end

  return getBasePart
end