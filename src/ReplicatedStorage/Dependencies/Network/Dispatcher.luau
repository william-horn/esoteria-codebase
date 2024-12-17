

return function()
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network

	local RemoteDispatcher = {}
	RemoteDispatcher.__index = RemoteDispatcher

	function RemoteDispatcher:validate()
		return { result = NetworkEnum.RemoteValidation.Successful }
	end

	function RemoteDispatcher:fire(headers, payload)
		-- print("remote fired with headers:", headers)
		-- print("remote fired with payload: ", payload)

		if (headers._allClients) then
			self.remote:FireAllClients(headers, payload)
		else
			for _, player in next, headers._toPlayers do
				self.remote:FireClient(player, headers, payload)
			end
		end
	end

	function RemoteDispatcher.new(RBXRemote, requests, channelSettings)
		local r = {}

		r.remote = RBXRemote
		r.requests = requests
		r.settings = channelSettings

		return setmetatable(r, RemoteDispatcher)
	end

	return { default = RemoteDispatcher }
end
