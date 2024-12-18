
# "Remotes" structure tree:

```lua
local Remotes = {
	TCP = {
		Client = {
			Events = {
				Player = { 
					remoteSettings = { 
						event = EventSignal,
						...
					}, 
					remote = Instance,
					...
				},
				...
			},
			...
		},
		Server = {
			...
		}
	},
	UDP = {
		...
	}
}
```

## Network API:


Remote event TCP API:

```lua
Network.sendTCP()
Network.sendAllTCP()
Network.sendListTCP()
Network.sendOthersTCP() -- this will call Network.sendListTCP() internally
```

Remote event UDP API:

```lua
Network.sendAllUDP()
Network.sendUDP()
Network.sendListUDP()
Network.sendOthersUDP()
```

Remote function API:
```lua
Network.request()
```


# Examples:

### **Server -> Client:**

```lua
Network.sendTCP(
	game.Players.JohnDoe,
	{
		channel = ChannelType.Player, 
		request = RequestType.GetPlayer
	},
	{
		...payload...
	}
)
```

### **Client -> Server:**

```lua
Network.sendTCP(
	{
		channel = ChannelType.Player, 
		request = RequestType.GetPlayer
	},
	{
		...payload...
	}
)
```

### **Server -> Client:**
### **Client -> Server:**

```lua
Network.sendAllTCP(
	{
		channel = ChannelType.Player, 
		request = RequestType.GetPlayer
	},
	{
		...payload...
	}
)

Network.sendOthersTCP() -- same signature as 'Network.sendAllTCP()'
```

### **Server -> Client:**
### **Client -> Server:**

```lua
Network.sendListTCP(
	{ ...players affected... },
	{
		channel = ChannelType.Player, 
		request = RequestType.GetPlayer
	},
	{
		...payload...
	}
)
```

for future reference:

A solved system of the form:
```
{
	T + C + E = 1
	T + S + E = 2
	T + C + F = 3
	T + S + F = 4
	L + C + E = 5
	L + S + E = 6
	L + C + F = 7
	L + S + F = 8
	U + C + E = 9
	U + S + E = 10
}
```

where:

	T = -2
	L = 2
	U = 6
	C = 1
	S = 2
	E = 2
	F = 4

and:

	T = TCP
	U = UDP
	L = Local
	C = Client
	S = Server
	E = Event
	F = Function

mapping:

	local toSystemVariable = {
		[MachineType.Client] = 1,
		[MachineType.Server] = 2,
		[ProtocolType.TCP] = -2,
		[ProtocolType.UDP] = 6,
		[ProtocolType.Local] = 2,
		[ChannelType.RemoteEvent] = 2,
		[ChannelType.RemoteFunction] = 4
	}