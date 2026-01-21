--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local forceBubbleChatRemote: Remote.Class? = nil
local Remote = require(modules.Objects.Remote)
local TextChatService = game:GetService("TextChatService")

return function(playerOrCharacter: Player | Model?, characterOrText: Model | string, textOrNil: string?)
	if isServer then
		if typeof(playerOrCharacter) ~= "Instance" or not playerOrCharacter:IsA("Player") then
			error("First argument must be Player on Server")
		elseif typeof(characterOrText) ~= "Instance" or not characterOrText:IsA("Model") then
			error("Second argument must be Character on Server")
		elseif typeof(textOrNil) ~= "string" then
			error("Third argument must be String on Server")
		end
		if not forceBubbleChatRemote then
			forceBubbleChatRemote = Remote.new("ForceBubbleChat", "Event")
		end
		forceBubbleChatRemote:fireClient(playerOrCharacter, characterOrText, textOrNil)
	else
		if playerOrCharacter ~= nil and (typeof(playerOrCharacter) ~= "Instance" or not playerOrCharacter:IsA("Model")) then
			error("First argument must be Character on Client")
		elseif typeof(characterOrText) ~= "string" then
			error("Second argument must be String on Client")
		elseif textOrNil ~= nil then
			error("Third argument must be Nil on Client")
		end
		if playerOrCharacter then
			TextChatService:DisplayBubble(playerOrCharacter, characterOrText)
		end
	end
end