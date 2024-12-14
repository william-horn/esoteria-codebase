
return function()
	local _isStudio = game:GetService("RunService"):IsStudio()

	local function isStudio()
		return _isStudio
	end

	return isStudio
end
