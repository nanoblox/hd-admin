--!strict
local Users = {}
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services


-- Setup player user objects (and their data saving and replication)
local User = require(modules.Objects.User)
local function playerAdded(player: Player)

	-- Create user
	User.new(player, "PlayerStore")

	-- Wait for user to load (or player to leave)
	local success, user = User.getUserAsync(player)
	if not success or not user then
		return
	end

	-- Listen for chatted
	local Commands = require(services.Commands)
	player.Chatted:Connect(function(message)
		local Parser = require(modules.Parser)
		local batch = Parser.parseMessage(message, user)
		local approved, notices, tasks = Commands.processBatchAsync(user, batch)
		print("batch, approved, notices, tasks =", batch, approved, notices, tasks)
	end)

end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end


-- Setup commands if the client makes a request before the server needs to update
-- This is essential for example to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.firstFetchRequested:connect(function()
	local Commands = require(services.Commands)
	Commands.updateCommands()
end)


return Users