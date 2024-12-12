
return function()
  local getBasePart = require(script.Parent.createBall)()

  local function getCharacterPlatform(parent)
    local platform = getBasePart()
    platform.Transparency = 0.5
    platform.BrickColor = BrickColor.Red()
    platform.Size = Vector3.new(10, 1, 10)
    platform.Parent = parent

    return platform
  end

  return getCharacterPlatform
end