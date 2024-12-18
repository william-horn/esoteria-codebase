
return function(import)
	return function(headers, payload)
		print("TCP Function Generic listener got: ", headers, payload)
	end
end
