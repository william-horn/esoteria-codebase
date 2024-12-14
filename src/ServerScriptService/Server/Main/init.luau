
return function(import, pm)
	local EventSignal = import("EventSignal")

	local e = EventSignal.new()

	e.connect({
		handler = function()
			print("fired")
		end
	})

	-- local withDotMethod = import("@Util/withDotMethod")

	-- local t, _t = withDotMethod()

	-- function t:test()
	-- 	return self.name .. ' - worked'
	-- end

	-- function t:new()
	-- 	local o = setmetatable({}, _t)
	-- 	o.name = "john"

	-- 	return o
	-- end

	-- print(t.new().test())
	-- print(t.test())

end
