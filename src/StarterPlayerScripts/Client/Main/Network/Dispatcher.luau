

return function(import)
	local Enums = game.ReplicatedStorage.Enums
	local NetworkEnum = Enums.Network
	local RemoteValidation = NetworkEnum.RemoteValidation

	local getRemoteInfo = import("@Network/getRemoteInfo")

	local RemoteDispatcher = {}
	RemoteDispatcher.instances = {}
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

		local dispatchSignal = self.remoteInfo.dispatch
		self.remote[dispatchSignal](self.remote, headers, payload)
	end

	function RemoteDispatcher:hasHandlers()
		return next(self.requestHandlers) ~= nil
	end

	function RemoteDispatcher.new(RBXRemote, requestHandlers, channelSettings)
		local r = setmetatable({}, RemoteDispatcher)

		r.remote = RBXRemote
		r.requestHandlers = requestHandlers
		r.channelSettings = channelSettings
		r.remoteInfo = getRemoteInfo(RBXRemote)

		RemoteDispatcher.instances[#RemoteDispatcher.instances + 1] = r
		return r
	end

	return { default = RemoteDispatcher }
end
