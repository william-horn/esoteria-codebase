
--[[
	Download the network data from the initial game folders into
	an internal model that the API will reference for outgoing
	requests.
]]

return function(import, global, pm)
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network
	local Channel, Request = NetworkEnum.Channel, NetworkEnum.Request
	local ProtocolType = NetworkEnum.ProtocolType

	-- Dependencies
	local getEnumByNameFrom = import("@Util/@Types/enum*", "getEnumByNameFrom")
	local isModule, isRemote = import("@Util/@Types", "isModule", "isRemote")
	local isClient, isServer = import("@System", "isClient", "isServer")

	return function(from, RemoteDispatcher)
		local protocols = {}

		--[[
			--------------------------------------------------------
			| # Construct the channel data from the channel folder |
			--------------------------------------------------------
		]]
		local function getRemoteDispatcherFromFolder(channelFolder, channelEnum, protocolFolder)
			local requests = {}

			local channelSettings = channelFolder:FindFirstChild("Settings")
			local requestModules = channelFolder:FindFirstChild("Handlers")
			local RBXRemote

			if (isClient()) then
				RBXRemote = channelFolder:FindFirstChild("Remote")
			
			elseif (isServer()) then
				RBXRemote = global.Network[protocolFolder.Name]:FindFirstChild(channelFolder.Name)
			end

			-- ! error:
			-- If no ROBLOX remote instance exists in the folder
			if (not RBXRemote) then
				error("Channel folder does not contain a ROBLOX Remote object, or it is not named \"Remote\"")
				
			elseif (not isRemote(RBXRemote)) then
				error("Channel folder contains an object named \"Remote\" but it is not a ROBLOX Remote instance.")
			end

			-- Channel settings exists
			if (channelSettings and isModule(channelSettings)) then
				channelSettings = require(channelSettings)

			-- warn:
			-- Channel settings exists but is not a ModuleScript
			elseif (channelSettings) then 
				warn("Found a \"Settings\" object in a remote channel but it is not a ModuleScript.")

			else
				channelSettings = {}
			end

			-- warn: 
			-- No request folder is found in channel folder
			if (not requests) then
				warn("No requests folder was found in channel: \"" .. channelFolder.Name .. "\"")

			-- Otherwise, scan the request handlers...
			else
				for _, requestModule in next, requestModules:GetChildren() do
					if (not isModule(requestModule)) then
						continue
					end

					local requestEnum = getEnumByNameFrom(Request, requestModule.Name)

					-- warn:
					-- If a request handler module does not have a corresponding Enum representation
					if (not requestEnum) then
						warn("Ignoring request handler \"" .. requestModule.Name .. "\" - (no corresponding Enum was found)")
						continue
					end

					-- add the required handler to the internal requests table in channel data
					-- "true" argument to require without looking for a default export
					requests[requestEnum] = { 
						process = pm.require(requestModule, true), 
						cache = nil -- should be a table {} when it gets created
					}
				end
			end

			return RemoteDispatcher.new(
				channelEnum,
				RBXRemote, 
				requests, 
				channelSettings
			)
		end

		--[[
			-------------------------
			| # Scan Network folder |
			-------------------------
		]]
		for _, protocolFolder in next, from:GetChildren() do
			local protocolType = getEnumByNameFrom(ProtocolType, protocolFolder.Name)

			if (not protocolType) then
				warn("Ignoring protocol folder \"" .. protocolFolder.Name .. "\" - (no corresponding Enum was found)")
				continue
			end

			local channels = {}

			-- assign the protocol data
			protocols[protocolType] = channels

			for _, channelFolder in next, protocolFolder:GetChildren() do
				local channelEnum = getEnumByNameFrom(Channel, channelFolder.Name)

				if (not channelEnum) then
					warn("Ignoring Channel folder \"" .. channelFolder.Name .. "\" - (no corresponding Enum was found)")
					continue
				end

				-- assign the channel data
				channels[channelEnum] = getRemoteDispatcherFromFolder(channelFolder, channelEnum, protocolFolder)
			end
		end

		return protocols
	end
end
