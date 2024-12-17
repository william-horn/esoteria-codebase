
return function(import)
	-- Dependencies
	local isClient = import("@System", "isClient")

	local isBindableEvent, 
	isBindableFunction, 
	isRemoteEvent, 
	isRemoteFunction = import(
		"@Util/@Types", 
		"isBindableEvent", 
		"isBindableFunction",
		"isRemoteEvent",
		"isRemoteFunction"
	)

	local function getSignalNamesFromRemote(remote)
		local signalNames = {}

		if (isRemoteEvent(remote)) then
			signalNames.connect = isClient() and "OnClientEvent" or "OnServerEvent"
			signalNames.dispatch = isClient() and "FireServer" or "FireClient"

		elseif (isRemoteFunction(remote)) then
			signalNames.connect = isClient() and "OnClientInvoke" or "OnServerInvoke"
			signalNames.dispatch = isClient() and "InvokeServer" or "InvokeClient"

		elseif (isBindableEvent(remote)) then
			signalNames.connect = "Event"
			signalNames.dispatch = "Fire"

		elseif (isBindableFunction(remote)) then
			signalNames.connect = "OnInvoke"
			signalNames.dispatch = "Invoke"
		end

		return signalNames
	end

	return getSignalNamesFromRemote
end
