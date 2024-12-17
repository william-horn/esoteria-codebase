
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
