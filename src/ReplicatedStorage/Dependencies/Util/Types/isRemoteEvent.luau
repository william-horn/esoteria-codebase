
return function()
	local function isRemoteEvent(v)
		return v:IsA("BaseRemoteEvent")
	end

	return isRemoteEvent
end 
