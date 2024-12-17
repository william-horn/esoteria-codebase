
return function()
	local function isRemoteFunction(v)
		return v:IsA("RemoteFunction")
	end

	return isRemoteFunction
end 
