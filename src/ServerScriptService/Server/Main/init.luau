
return function(import, pm)
	local event = import("EventSignal")

	local e = event.new()

	e:connect({
		handler = function()
			print("fired")
		end
	})

	e:fire()
end
