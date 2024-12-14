
return function(import)
	local CustomType = import("../@Enums/CustomType*")
	local withDotMethod = import("@Util/withDotMethod")

	local Connection, _Connection = withDotMethod()

	function Connection:pause()
		self.active = false
	end

	function Connection:resume()
		self.active = true
	end

	function Connection:isActive()
		return self.active
	end

	function Connection:new(options)
		local connection = setmetatable({}, _Connection)

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
