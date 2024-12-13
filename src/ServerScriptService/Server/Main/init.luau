
return function(import, pm)
	local enums = pm.from("../Enums/Network")
  -- local NetworkType, NetworkRequest = enums.import("NetworkType", "NetworkRequest")

	local NetworkType, NetworkRequest = import("../@Enums/@Network", "@NetworkType/@.")
	-- local NetworkType, NetworkRequest = import("../@Enums/@Network", "NetworkType", "NetworkRequest")


  print("NetworkRequest: ", NetworkRequest)
	print("NetworkType: ", NetworkType)
end