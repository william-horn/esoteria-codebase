--[[
	@author: William J. Horn
	@written: 11/26/2024

	Coming soon
]]

return function(_, _, pm)
	-- require modules
	local PlayerDataSchema = require(script.Schema)
	local Seed = pm.require(script.Seed, true)

	local PlayerDataTemplate = {}
	PlayerDataTemplate.__index = PlayerDataTemplate

	--[[
		@desc: Resets all data to default values
		@return PlayerDataTemplate
	]]
	function PlayerDataTemplate:reset()
		for key, val in pairs(self.data) do
			self.data[key] = PlayerDataSchema[key]
		end

		return self
	end

	--[[
		@desc: Randomizes all data to random values
		@return PlayerDataTemplate
	]]
	function PlayerDataTemplate:randomize()
		local data = self.data

		data.nickname = Seed:randomName()
		data.classification = Seed:randomClassification()

		data.stats.level = Seed:randomLevel()
		data.stats.healthRatio = Seed:randomHealth()
		data.stats.manaRatio = Seed:randomMana()
		data.stats.experience = Seed:randomExperience()

		data.currency.gold = Seed:randomGold()
		data.currency.emeralds = Seed:randomEmeralds()

		return self
	end

	--[[
		@desc: Creates a new PlayerDataTemplate instance
		@return PlayerDataTemplate
	]]
	function PlayerDataTemplate.new()
		local playerData = table.clone(PlayerDataSchema)
		playerData.info.joinDate = DateTime.now().UnixTimestampMillis

		local playerDataObject = {
			data = playerData
		}

		return setmetatable(playerDataObject, PlayerDataTemplate)
	end


	return PlayerDataTemplate
end
