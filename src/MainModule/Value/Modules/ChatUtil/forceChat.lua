--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local forceChatRemote: Remote.Class? = nil
local Remote = require(modules.Objects.Remote)
local TextChatService = game:GetService("TextChatService")

return function(playerOrText: Player | string, text: string?)
	if isServer then
		if typeof(playerOrText) ~= "Instance" or not playerOrText:IsA("Player") then
			error("First argument must be a Player when called from Server")
		end
		if not forceChatRemote then
			forceChatRemote = Remote.new("ForceChat", "Event")
		end
		forceChatRemote:fireClient(playerOrText, text)
	else
		if typeof(playerOrText) == "Instance" then
			error("First argument must be a string when called from Client")
		end
		local textChannels = TextChatService:WaitForChild("TextChannels", 3)
		local generalChannel = textChannels and textChannels:FindFirstChild("RBXGeneral")
		local textToSend = playerOrText
		if generalChannel and generalChannel:IsA("TextChannel") and typeof(textToSend) == "string" then
			generalChannel:SendAsync(textToSend)
		end
	end
end