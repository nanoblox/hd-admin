--!strict
local Players = game:GetService("Players")

-- Cancel run if another application has initialized
local modules = script:FindFirstAncestor("MainModule").Value.Modules
if require(modules.Framework).startAsync() == false then
    return
end

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
	local Commands = require(modules.Commands)
	player.Chatted:Connect(function(message)
		local Parser = require(modules.Parser)
		local batch = Parser.parseMessage(message, user)
		Commands.processBatchAsync(user, batch)
	end)

end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end