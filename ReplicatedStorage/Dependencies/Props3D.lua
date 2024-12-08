local Props = {}

local function getBasePart()
	local part = Instance.new('Part')
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Anchored = true
	part.CanCollide = false
	
	return part
end

function Props.getBall(parent)
	local prop = getBasePart()
	prop.Shape = Enum.PartType.Ball
	prop.BrickColor = BrickColor.Blue()
	prop.Size = Vector3.new(1, 1, 1)
	prop.Transparency = 0.5
	prop.Parent = parent
	
	return prop
end

function Props.getCharacterPlatform(parent)
	local platform = getBasePart()
	platform.Transparency = 0.5
	platform.BrickColor = BrickColor.Red()
	platform.Size = Vector3.new(10, 1, 10)
	platform.Parent = parent
	
	return platform
end

return Props