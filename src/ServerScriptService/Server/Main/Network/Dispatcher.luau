

return function()
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network
	local RemoteValidation = NetworkEnum.RemoteValidation

	local RemoteDispatcher = {}
	RemoteDispatcher.__index = RemoteDispatcher

	function RemoteDispatcher:validate(validator) -- make validator an optional callback function that returns conditional validated logic
		return { result = NetworkEnum.RemoteValidation.Successful }
	end

	function RemoteDispatcher:fire(headers, payload)
		-- ! REMOTE VALIDATION CHECK HERE
		-- validate remote call against `channelSettings` and possibly `headers`
		local remoteValidation = self:validate()

		if (remoteValidation.result == RemoteValidation.Rejected) then
			warn("Remote validation failed for channel: \"" .. headers.channel.Name .. "\" with request: \"" .. headers.request.Name .. "\"")
			return
		end

		local dispatchSignal = self.channelSettings.remoteSignalNames.dispatch

		-- remote call is FireAllClients()
		if (headers._allClients and self.remote.FireAllClients) then
			self.remote:FireAllClients(headers, payload)

		elseif (headers._allClients) then
			-- ! error: 
			error("Attempt to declare header \"_addClients\" on a non-RemoteEvent")

		-- remote call is firing to players
		elseif (headers._toPlayers) then
			for _, player in next, headers._toPlayers do
				self.remote[dispatchSignal](self.remote, player, headers, payload)
			end

		-- remote call must be from the client
		else
			self.remote[dispatchSignal](self.remote, headers, payload)
		end
	end

	function RemoteDispatcher.new(RBXRemote, requests, channelSettings)
		local r = {}

		r.remote = RBXRemote
		r.requests = requests
		r.channelSettings = channelSettings

		return setmetatable(r, RemoteDispatcher)
	end

	return { default = RemoteDispatcher }
end
