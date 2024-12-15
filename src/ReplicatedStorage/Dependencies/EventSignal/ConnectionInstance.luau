
return function(import)
	local Enums = game.ReplicatedStorage.Enums
	local CustomType = Enums.CustomType
	-- local withDotMethod = import("@Util/withDotMethod")

	local Connection = {}
	Connection.__index = Connection

	function Connection:pause()
		self.active = false
	end

	function Connection:resume()
		self.active = true
	end

	function Connection:isActive()
		return self.active
	end

	function Connection.new(options)
		local connection = setmetatable({}, Connection)

		connection.priority = options.priority
		connection.name = options.name or "Connection__Generic"
		connection.handler = options.handler
		connection.connection = connection
		connection.active = true

		connection._customType = CustomType.ConnectionInstance

		return connection
	end

	return {
		default = Connection
	}
end
