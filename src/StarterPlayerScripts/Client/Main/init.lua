
return function(import, _, pm)
	local packages = pm.from(script.Dependencies)

	local Network = packages.import("Network"):init()
	local UserInputHandler = packages.import("UserInputHandler"):init()
	local CustomCamera = packages.import("CustomCamera"):init()

end

