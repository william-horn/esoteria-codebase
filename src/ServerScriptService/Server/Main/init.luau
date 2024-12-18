
return function(import, global, pm)
	local packages = pm.from(script.Dependencies)

	local Network = packages.import("Network"):init()
	local PlayerManager = packages.import("PlayerManager"):init()

end
