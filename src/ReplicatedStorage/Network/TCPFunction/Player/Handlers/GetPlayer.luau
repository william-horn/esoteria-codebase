return function(import)

	
	return function(headers, payload)
		print("Client received headers: ", headers)
		print("Client payload: ", payload)
	end
end