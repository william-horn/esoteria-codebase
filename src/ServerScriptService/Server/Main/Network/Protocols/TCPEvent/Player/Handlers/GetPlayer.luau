return function(import)
	
	return function(headers, payload)
		print("Server: Handler ran with headers: ", headers)
		print("Server: With paload: ", payload)
	end
end
