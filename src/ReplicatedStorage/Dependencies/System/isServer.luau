
return function()
	local _isServer = game:GetService("RunService"):IsServer()

	local function isServer()
		return _isServer
	end

	return isServer
end
