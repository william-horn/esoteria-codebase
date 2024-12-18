
return function(import)
	return function(headers, payload)
		print("Local Event Generic listener got: ", headers, payload)
	end
end
