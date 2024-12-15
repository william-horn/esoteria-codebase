
return function(import)
	local NetworkFolder = game.ReplicatedStorage.Network
	-- local Enums = game.ReplicatedStorage.Enums

	local aliases = require(script.Parent.Aliases)
	local protocolFolderToEnum = aliases.protocolFolderToEnum
	local machineTypeToEnum = aliases.machineTypeToEnum
	local remoteTypeFolderToEnum = aliases.remoteTypeFolderToEnum
	local remoteChannelFolderToEnum = aliases.remoteChannelFolderToEnum

	local deepCopy = import("@Table/deepCopy")

	local errorPre = "Failed to build network: "

	local networkDepthMap = {
		protocolFolderToEnum,
		machineTypeToEnum,
		remoteTypeFolderToEnum,
		remoteChannelFolderToEnum
	}

	local function createRemoteDispatcher(folder)
		local settings = folder:FindFirstChild("_settings")
		local util = folder:FindFirstChild("Util")
		local handlers = folder:FindFirstChild("Handlers")


	end

	local function buildNetwork()
		local function cycle(got)
			if (got.depth == 4) then
				got.terminate = true
				return
			end

			local toEnum = networkDepthMap[depth]
			local enum = toEnum[value.Name]

			if (not value) then 
				error()
			end

			return enum, value:GetChildren()
		end

		return deepCopy(NetworkFolder:GetChildren(), cycle)
	end

	return buildNetwork()
end
