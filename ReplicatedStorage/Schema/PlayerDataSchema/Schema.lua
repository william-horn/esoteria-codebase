
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
		experience = 0,
		healthRatio = 0,
		manaRatio = 0,
		level = 0,
		movementSpeed = 8,
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
