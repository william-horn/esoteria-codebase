
return function()
	local _isClient = game:GetService("RunService"):IsClient()

	local function isClient()
		return _isClient
	end

	return isClient
end
