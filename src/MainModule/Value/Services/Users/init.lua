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
		local approved, notices, tasks = Commands.request(user, message)
		print("approved, notices, tasks =", approved, notices, tasks)
		for _, noticeTable in notices do
			local isWarning = noticeTable[1] == false
			local string = noticeTable[2]
			local initial = `[HD Admin {isWarning and "WARNING" or "Notice"}]: `
			warn(initial..string)
		end
	end)

end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end


-- Setup commands and roles if the client makes a request before the server needs to update
-- This is essential for example to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.firstFetchRequested:Connect(function()
	local Commands = require(services.Commands)
	local Roles = require(services.Roles)
	Commands.updateCommands()
	Roles.updateRoles()
end)


return Users