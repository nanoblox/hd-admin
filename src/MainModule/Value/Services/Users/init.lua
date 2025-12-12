--!strict
local Users = {}
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Config = require(modules.Parent.Services.Config)
local User = require(modules.Objects.User)

-- Setup player user objects (and their data saving and replication)
local minimumAccountAge = tonumber(Config.getSetting("MinimumAccountAge")) or 0
local function playerAdded(player: Player)
	-- Check if player's account is old enough to join.
    if minimumAccountAge > 0 and player.AccountAge < minimumAccountAge then
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
		Commands.processNotices(player, notices)
	end)

	-- Listen for silent /e chat commands
	local Players = game:GetService("Players")
	local TextChatService = game:GetService("TextChatService")
	for _, instance in TextChatService:GetDescendants() do
		if not (instance:IsA("TextChatCommand") and instance.SecondaryAlias == "/e") then
			continue
		end
		instance.Triggered:Connect(function(chatSource, message)
			local speaker = Players:FindFirstChild(chatSource.Name) :: Player?
			if not speaker or speaker ~= player then
				return
			end
			local finalMessage = string.sub(message,4)
			local approved, notices, tasks = Commands.request(user, finalMessage, "ChatCommand")
			Commands.processNotices(speaker, notices)
		end)
	end

end
Players.PlayerAdded:Connect(playerAdded)
for _, player in Players:GetPlayers() do
	playerAdded(player)
end


return Users
