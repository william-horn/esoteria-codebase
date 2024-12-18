
return function(import)
	local connectionType = game.ReplicatedStorage.Enums.ConnectionType

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

	local function getRemoteInfo(remote)
		local remoteInfo = {}

		if (not remote) then
			remoteInfo.connectionType = connectionType.None
			return remoteInfo
		end

		if (isRemoteEvent(remote)) then
			remoteInfo.listener = isClient() and "OnClientEvent" or "OnServerEvent"
			remoteInfo.dispatch = isClient() and "FireServer" or "FireClient"
			remoteInfo.connectionType = connectionType.Event

		elseif (isRemoteFunction(remote)) then
			remoteInfo.listener = isClient() and "OnClientInvoke" or "OnServerInvoke"
			remoteInfo.dispatch = isClient() and "InvokeServer" or "InvokeClient"
			remoteInfo.connectionType = connectionType.Callback

		elseif (isBindableEvent(remote)) then
			remoteInfo.listener = "Event"
			remoteInfo.dispatch = "Fire"
			remoteInfo.connectionType = connectionType.Event

		elseif (isBindableFunction(remote)) then
			remoteInfo.listener = "OnInvoke"
			remoteInfo.dispatch = "Invoke"
			remoteInfo.connectionType = connectionType.Callback
		end

		return remoteInfo
	end

	return getRemoteInfo
end
