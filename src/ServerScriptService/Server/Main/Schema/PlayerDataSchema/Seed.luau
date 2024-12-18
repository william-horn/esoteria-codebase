
return function(import, global, pm)
	-- config
	local GameConfig = pm.require(global.ServerScripts.Server.Main.Config, true)

	-- enums
	local PlayerClassification = game.ReplicatedStorage.Enums.Player.Classification

	local names = {
		"Aragorn", 
		"Gandalf", 
		"Legolas", 
		"Frodo", 
		"Gimli", 
		"Bilbo", 
		"Thorin", 
		"Gollum", 
		"Sauron", 
		"Saruman"
	}

	local Seed = {}

	function Seed:randomName()
		return names[math.random(1, #names)]
	end

	function Seed:randomClassification()
		local classes = PlayerClassification:GetChildren()
		return classes[math.random(1, #classes)].Name
	end

	function Seed:randomLevel()
		return math.random(GameConfig.Player.universal_level_limit)
	end

	function Seed:randomHealth()
		return math.random()
	end

	function Seed:randomMana()
		return math.random()
	end

	function Seed:randomGold()
		return math.random(1, GameConfig.Player.universal_gold_limit)
	end

	function Seed:randomEmeralds()
		return math.random(1, GameConfig.Player.universal_emerald_limit)
	end

	function Seed:randomExperience()
		return math.random(1, GameConfig.Player.universal_exp_limit)
	end


	return Seed
end
