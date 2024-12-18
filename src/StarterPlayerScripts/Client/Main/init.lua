
return function(import, _, pm)
	local packages = pm.from(script.Dependencies)

	local Network = packages.import("Network"):init()
	local UserInputHandler = packages.import("UserInputHandler"):init()
	local CustomCamera = packages.import("CustomCamera"):init()

	CustomCamera:setMode(game.ReplicatedStorage.Enums.CameraMode.TrackPlayerNormal)
	
	local c = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

	CustomCamera:setTarget(c.HumanoidRootPart)

end

