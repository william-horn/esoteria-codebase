

return function()
  local getBasePart = require(script.Parent.createBall)()

  local function getBall(parent)
    local part = getBasePart()
    part.Shape = Enum.PartType.Ball
    part.BrickColor = BrickColor.Blue()
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 0.5
    part.Parent = parent

    return part
  end

  return getBall
end