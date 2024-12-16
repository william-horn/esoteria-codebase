
return function()
	local function isRemote(v)
		return v:IsA("BaseRemoteEvent") 
			or v:IsA("BindableEvent") 
			or v:IsA("BindableFunction")
			or v:IsA("RemoteFunction")
	end

	return isRemote
end