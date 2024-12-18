
return {
	nickname = '',
	classification = '',
	
	info = {
		-- join date?
	},
	
	-- must contain actual quest objects (can be shortened versions, only needs to contain saved objectives)
	-- all other data can be looked up again later
	activeQuests = {
		--{ 
		--	id = 'quest_id',
		--	objectives = {...}
		--}
	}, 
	
	completedQuests = {
		--'quest_id',
		--'quest_id',
	}, 
	
	stats = {
		currentExperience = 0,
		currentHealth = 0,
		currentMana = 0,
		
		level = 0,
		
		-- all other starts will be based on user's level/other factors
	},
	
	currency = {
		gold = 0,
		emeralds = 0,
	},
	
	inventory = {
		
	},
	
	settings = {
		sound = {},
		camera = {},
		mouse = {},
		gui = {
			chat = {},
		}
	}
}
