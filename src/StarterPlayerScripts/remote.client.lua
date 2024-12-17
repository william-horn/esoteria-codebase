
print("----------- On client: ----------------------------------------")

local r = game.ReplicatedStorage.Network.TCPOnClientEvent.Player.Remote.OnClientEvent:Connect(function(...)
	print("got: ", ...)
end)