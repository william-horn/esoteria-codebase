
return function(import)
	return function(headers, payload)
		print("Local Function Generic listener got: ", headers, payload)
	end
end
