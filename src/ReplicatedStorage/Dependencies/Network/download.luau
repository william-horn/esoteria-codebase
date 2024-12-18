
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
	local System = import("System")
	local getEnumByNameFrom = import("@Util/@Types/enum*", "getEnumByNameFrom")
	local isModule, isRemote = import("@Util/@Types", "isModule", "isRemote")

	return function(to, RemoteDispatcher)
		local protocols = {}

		--[[
			--------------------------------------------------------
			| # Construct the channel data from the channel folder |
			--------------------------------------------------------
		]]
		local function coalesceChannelDataFromFolders(channelFolder, sourceChannelFolder)
			local channelData = {}
			channelData.outgoingCache = {}
			channelData.incomingCache = {}

			local requestHandlers = {}
			local channelSettings = {}

			local RBXRemote = channelFolder:FindFirstChild("Remote")

			-- Check for a ROBLOX remote
			if (not RBXRemote) then
				error("Channel folder \"" .. channelFolder.Name .. "\" is missing a Remote")

			elseif (not isRemote(RBXRemote)) then
				error("Channel folder \"" .. channelFolder.Name .. "\" contains an object named \"Remote\" but it is not a ROBLOX Remote")
			end

			-- Check for synchronization with source folder
			if (not sourceChannelFolder) then
				warn("Channels could not sync properly, missing channel \"" .. channelFolder.Name .. "\" in \"" .. tostring(channelFolder.Parent) .. "\" on the " .. System.MachineType.Name)
			else
				local requestHandlersFolder = sourceChannelFolder:FindFirstChild("Handlers")

				if (not requestHandlersFolder) then
					warn("No request handlers were found in channel \"" .. channelFolder.Name .. "\"")
				else
					for _, requestModule in next, requestHandlersFolder:GetChildren() do
						if (not isModule(requestModule)) then
							warn("Found object in request handler folder \"" .. requestModule:GetFullName() .. "\" which is not a ModuleScript")
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
						requestHandlers[requestEnum] = { 
							process = pm.require(requestModule, true) 
						}
					end
				end
			end

			local remoteDispatcher = RemoteDispatcher.new(
				RBXRemote,
				requestHandlers,
				channelSettings
			)

			channelData.dispatcher = remoteDispatcher

			return channelData
		end

		--[[
			-------------------------
			| # Scan Network folder |
			-------------------------
		]]
		for _, protocolFolder in next, global.Network:GetChildren() do
			local protocolType = getEnumByNameFrom(ProtocolType, protocolFolder.Name)
			local sourceProtocolFolder

			if (not protocolType) then
				warn("Ignoring protocol folder \"" .. protocolFolder.Name .. "\" - (no corresponding Enum was found)")
				continue
			end

			sourceProtocolFolder = to:FindFirstChild(protocolFolder.Name)

			if (not sourceProtocolFolder) then
				error("Network could not sync properly, missing protocol folder \"" .. protocolFolder.Name .. "\" in \"" .. to:GetFullName() .. "\"")
			end 

			local channels = {}

			-- assign the protocol data
			protocols[protocolType] = channels

			for _, channelFolder in next, protocolFolder:GetChildren() do
				local channelEnum = getEnumByNameFrom(Channel, channelFolder.Name)
				local sourceChannelFolder

				if (not channelEnum) then
					warn("Ignoring Channel folder \"" .. channelFolder.Name .. "\" - (no corresponding Enum was found)")
					continue
				end

				sourceChannelFolder = sourceProtocolFolder:FindFirstChild(channelFolder.Name)

				-- assign the channel data
				channels[channelEnum] = coalesceChannelDataFromFolders(channelFolder, sourceChannelFolder)
			end
		end

		return protocols
	end
end
