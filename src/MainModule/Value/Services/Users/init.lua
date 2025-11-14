--!strict
local Users = {}
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local configSettings = require(modules.Config.Settings)
local minAccAge = configSettings.PlayerSettings.MinAccAge

-- Setup player user objects (and their data saving and replication)
local User = require(modules.Objects.User)
local function playerAdded(player: Player)
	-- Check if player's account is old enough to join.
    if player.AccountAge < minAccAge then
        player:Kick("🚫 Your account is too new to join! 🚫")
        return
    end
	
	-- Create user
	User.new(player, "PlayerStore")

	-- Wait for user to load (or player to leave)
	local success, user = User.getUserAsync(player)
	if not success or not user then
		return
	end

	-- Listen for Chatted
	local Commands = require(services.Commands)
	player.Chatted:Connect(function(message)
		local approved, notices, tasks = Commands.request(user, message, "Chat")
		Commands.processNotices(notices)
	end)

	-- Listen for silent /e chat commands
	local Players = game:GetService("Players")
	local TextChatService = game:GetService("TextChatService")
	for _, instance in TextChatService:GetDescendants() do
		if not (instance:IsA("TextChatCommand") and instance.SecondaryAlias == "/e") then
			continue
		end
		instance.Triggered:Connect(function(chatSource, message)
			local speaker = Players:FindFirstChild(chatSource.Name)
			if not speaker then
				return
			end
			local finalMessage = string.sub(message,4)
			local approved, notices, tasks = Commands.request(user, finalMessage, "ChatCommand")
			Commands.processNotices(notices)
		end)
	end

end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end


return Users
