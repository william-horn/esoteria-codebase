
return function(import)
	return function(headers, payload)
		print("UDP Generic listener got: ", headers, payload)
	end
end
