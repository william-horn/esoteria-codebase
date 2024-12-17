
return function(import, global, pm)

	local enums = game.ReplicatedStorage.Enums.Network
	local network = pm.from(script).import("Network")

	print("Network: ", network)

	local p = game.Players:WaitForChild("ScriptGuider")

	network:init()

	network:sendTCP(
		{
			channel = enums.Channel.Player,
			request = enums.Request.GetPlayer,
			_dependencies = {"same"},
			_toPlayers = {p}
		},
		{
			data = "test"
		}
	)

	print("==========================")

	network:sendTCP(
		{
			channel = enums.Channel.Player,
			request = enums.Request.GetPlayer,
			_dependencies = {"same0"},
			_toPlayers = {p}
		},
		{
			data = "test"
		}
	)

	print("==========================")

	network:sendTCP(
		{
			channel = enums.Channel.Player,
			request = enums.Request.GetPlayer,
			_dependencies = {"same0"},
			_toPlayers = {p}
		},
		{
			data = "test"
		}
	)

	print("==========================")


	-- for i = 1, 100 do
	-- 	network:sendTCPAll(
	-- 		{
	-- 			channel = enums.Channel.Player,
	-- 			request = enums.Request.GetPlayer,
	-- 			_dependencies = {"same"},
	-- 		},
	-- 		{
	-- 			data = i
	-- 		}
	-- 	)
	-- end
	-- local e = os.clock()
	-- print("sendTCP took: ", e - t)

	-- local withDotMethod = import("@Util/withDotMethod")
	-- local deepCopy = import("@Table/deepCopy")

	-- local t = import("@Util/testing")

	-- print(t)

	-- print(pm.require(game.ReplicatedStorage.Dependencies.Network.BuildNetwork, true))

	-- local t = deepCopy(workspace.MasterRoot:GetChildren(), function(got)
	-- 	local c = got.value:GetChildren()
	-- 	local a = #c > 0 and c or got.value

	-- 	if (got.depth == 3) then
	-- 		got.terminate = true
	-- 		return 
	-- 	end

	-- 	got.key = got.value.Name
	-- 	got.value = a
	-- end)

	-- print("tree: ", t)

	-- local t, _t = withDotMethod()

	-- function t:new()
	-- 	return setmetatable({}, getmetatable(self))
	-- end

	-- function t:getFirst(first)
	-- 	local t2 = self.new()
	-- 	t2.added = { index = first }

	-- 	return t2
	-- end 

	-- function t:getSecond(name)
	-- 	return self.added[name]
	-- end

	-- local o = t.new()

	-- print(o.getFirst("something").getSecond("index"))

	-- print(t.getFirst("idk"))
	-- print(o.getFirst == t.getFirst)
end
