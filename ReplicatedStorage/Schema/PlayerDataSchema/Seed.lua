
local ReplicatedStorage = game:GetService('ReplicatedStorage')

-- paths
local Path__GameConfig = ReplicatedStorage.GameConfig
local Path__Dependencies = ReplicatedStorage.Dependencies
local GlobalEnums = require(Path__Dependencies.Enums)

-- dependencies
local Table = require(Path__Dependencies.TableFunctions)

-- enums
local PlayerClassification = GlobalEnums.PlayerClassification

-- config
local GameConfig = require(Path__GameConfig.Server)

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
	local classes = PlayerClassification:getEnums()
	return classes[math.random(1, #classes)]
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
