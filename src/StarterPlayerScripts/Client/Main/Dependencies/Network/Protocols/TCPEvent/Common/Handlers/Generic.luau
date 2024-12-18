
return function(import)
	return function(headers, payload)
		print("TCP Event Generic listener got: ", headers, payload)
	end
end
