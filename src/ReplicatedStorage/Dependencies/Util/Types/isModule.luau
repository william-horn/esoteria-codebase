
return function()
	local function isModule(v)
		return v:IsA("ModuleScript")
	end

	return isModule
end
