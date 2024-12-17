
return function()
	local function isBindableFunction(v)
		return v:IsA("BindableFunction")
	end

	return isBindableFunction
end 
