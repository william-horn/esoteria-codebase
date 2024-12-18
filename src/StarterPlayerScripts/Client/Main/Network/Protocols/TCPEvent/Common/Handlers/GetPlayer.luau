
return function(import)

	return function(headers, payload)
		print("Got from server: ", headers, payload)
	end
end
