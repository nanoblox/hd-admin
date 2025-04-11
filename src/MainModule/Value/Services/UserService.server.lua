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
	User.new(player, "PlayerStore")
end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end