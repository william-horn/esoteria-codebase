
return function()
	local function isBindableEvent(v)
		return v:IsA("BindableEvent")
	end

	return isBindableEvent
end 
