
return function(import, global, pm)

	local withDotMethod = import("@Util/withDotMethod")

	local t, _t = withDotMethod()

	function t:new()
		return setmetatable({}, getmetatable(self))
	end

	function t:getFirst(first)
		local t2 = self.new()
		t2.added = { index = first }

		return t2
	end 

	function t:getSecond(name)
		return self.added[name]
	end

	local o = t.new()

	print(o.getFirst("something").getSecond("index"))

	print(t.getFirst("idk"))
	print(o.getFirst == t.getFirst)
end
