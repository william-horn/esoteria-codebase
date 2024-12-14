
return function(import, pm)

	local d = pm.from(script)
	print(d)
	local EventSignal = import("EventSignal")

	local e = EventSignal.new()

	e.connect({
		handler = function()
			print("fired")
		end
	})

	e.fire()

	task.wait(1)

	e.fire()

	-- object.getName = nil
	-- Class.getName = nil
	-- Class.new = nil
	-- Class = nil

end
