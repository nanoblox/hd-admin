-- LOCAL
local ClientUsers = {}
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local sharedTypes = require(modules.References.sharedTypes)


-- SETUP
-- This is the new replacement for player.Chatted because a message can be
-- instantly processed by the server, instead of waiting first to be filtered
local sendMessage = Remote.get("SendMessage")
TextChatService.SendingMessage:Connect(function(message: TextChatMessage)
	-- It's important we only act upon the local client's own messages
	local sender = message.TextSource
	local messageText = message.Text
	if sender and sender.UserId == localPlayer.UserId then
		local chatSource: sharedTypes.MessageSource = "Chat"
		sendMessage:invokeServerAsync(messageText, chatSource)
	end
end)


return ClientUsers