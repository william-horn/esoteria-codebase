
return function(import)

	return function(headers, payload)
		print("from player: ", headers._fromPlayer)
		print(headers, payload)
	end
end
