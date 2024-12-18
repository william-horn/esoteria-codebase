
return function(import, _, pm)
	local packages = pm.from(script.Dependencies)

	local Network = packages.import("Network"):init()
end

