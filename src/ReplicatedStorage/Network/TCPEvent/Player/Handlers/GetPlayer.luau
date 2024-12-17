return function(import)

	
	return function(headers, payload)
		print("Client TCP Event received headers: ", headers)
		print("Client TCP Event payload: ", payload)
	end
end
