
return function(import)
	return function(headers, payload)
		print("Got session update from server: ", headers, payload)
	end
end
