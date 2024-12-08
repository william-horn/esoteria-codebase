--[[
Credit to jrus@github.com for UUID generation function
source: https://gist.github.com/jrus/3197011

to generate a new uuid in the output window:
print(require(game.ReplicatedStorage.Modules.UUID)())
]]

math.randomseed(os.clock())
local random = math.random

return function()
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end