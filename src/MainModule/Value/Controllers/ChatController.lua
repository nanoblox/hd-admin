--!strict
-- LOCAL
local ChatController = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local alreadyCreatedChatCommands = {}
local sendMessage = Remote.get("SendMessage")


-- SETUP
Remote.get("ForceChat"):onClientEvent(function(text: string)
	local forceChat = require(modules.ChatUtil.forceChat)
	forceChat(text)
end)

Remote.get("ForceBubbleChat"):onClientEvent(function(character: Model?, text: string)
	local forceBubbleChat = require(modules.ChatUtil.forceBubbleChat)
	forceBubbleChat(character, text)
end)

Remote.get("SystemMessage"):onClientEvent(function(text: string)
	local systemMessage = require(modules.ChatUtil.systemMessage)
	systemMessage(text)
end)


-- LOCAL FUNCTIONS
local function bindToEvent(eventName: string)
	(TextChatService :: any)[eventName]:Connect(function(message: TextChatMessage): TextChatMessage?
		local textSource = message.TextSource
		local sourcePlayer: Instance? = if textSource then Players:FindFirstChild(textSource.Name) else nil
		if not sourcePlayer or not sourcePlayer:IsA("Player") then
			return nil
		end
		local hdChatConfigEnabled = sourcePlayer:GetAttribute("HDChatConfigEnabled")
		if not hdChatConfigEnabled then
			return nil
		end
		local chatTag = sourcePlayer:GetAttribute("ChatTag") :: string?
		local chatTagColor = sourcePlayer:GetAttribute("ChatTagColor") :: Color3?
		local chatName = sourcePlayer:GetAttribute("ChatName") :: string?
		local chatNameColor = sourcePlayer:GetAttribute("ChatNameColor") :: Color3?
		if message.TextSource then
			local tagPrefix = chatTag and `[{chatTag}]`
			if tagPrefix and chatTagColor then
				tagPrefix = `<font color='#{chatTagColor:ToHex()}'>{tagPrefix}</font>`
			end
			local namePrefix = `{chatName or sourcePlayer.DisplayName}:`
			if namePrefix and chatNameColor then
				namePrefix = `<font color='#{chatNameColor:ToHex()}'>{namePrefix}</font>`
			end
			local finalPrefix = namePrefix
			if tagPrefix then
				finalPrefix = tagPrefix.." "..namePrefix
			end
			--
			local prefixText = message.PrefixText
			local prefixTextMinusRich = string.match(prefixText, "<.*>(.*)<.*>")
			if not chatTag and prefixTextMinusRich and typeof(prefixText) == "string" then
				-- This is in case the developer has already added their own prefix text
				-- and we need to capture the start and end of their prefix text
				local ts, te = string.find(string.reverse(prefixText),string.reverse(prefixTextMinusRich))
				if ts and te then
					local s,e = string.len(prefixText)-te+1,string.len(prefixText)-ts+1
					if s and e then
						local startCapture = string.sub(prefixText, 1, s-1)
						local startCaptureMinusRich = string.match(startCapture, "<.*>(.*)<.*>")
						local endCapture = string.sub(prefixText, e+1)
						if startCaptureMinusRich then
							startCapture = startCapture.." "
						end
						finalPrefix = startCapture..finalPrefix..endCapture
					end
				end
			end
			--
			message.PrefixText = finalPrefix
		end
		return message
	end)
end

local function createChatCommand(primaryAlias)
	if alreadyCreatedChatCommands[primaryAlias] then
		return
	end
	alreadyCreatedChatCommands[primaryAlias] = true
	local textChatCommand = Instance.new("TextChatCommand")
	textChatCommand.AutocompleteVisible = true
	textChatCommand.Enabled = true
	textChatCommand.PrimaryAlias = primaryAlias
	textChatCommand.Parent = TextChatService
	textChatCommand.Triggered:Connect(function(source: TextSource, text: string)
		if not source or source.UserId ~= localPlayer.UserId then
			return
		end
		local sharedTypes = require(modules.References.sharedTypes)
		local chatSource: sharedTypes.MessageSource = "ChatCommand"
		sendMessage:invokeServerAsync(text, chatSource)
	end)
end


-- PUBLIC FUNCTIONS
function ChatController.generateChatCommands(arrayOfCommandNames: {string})
	for _, primaryAlias in arrayOfCommandNames do
		createChatCommand(primaryAlias)
	end
end

function ChatController.decideWelcomePrompt()
	createChatCommand("/dance")
	createChatCommand("/backflip")
	createChatCommand("/commands")
	createChatCommand("/helicopter")
	createChatCommand("/plane")
	createChatCommand("/reset")
end


-- SETUP
-- This sets-up ChatService related functions
bindToEvent("SendingMessage")
bindToEvent("MessageReceived")
task.defer(ChatController.decideWelcomePrompt)

-- This fixes a bug within TextChatService that prevents
-- TextChatCommands from showing
task.defer(function()
	local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	task.wait(1)
	local command = Instance.new("TextChatCommand")
	command.PrimaryAlias = "/zzz"
	command.Enabled = true
	command.AutocompleteVisible = true
	command.Name = "FixChat"
	command.Parent = TextChatService
	task.delay(0.25, function()
		command.Enabled = false
		command.AutocompleteVisible = false
		task.wait(0.25)
		command:Destroy()
	end)
end)


--[[
TextChatService.OnChatWindowAdded = function(message: TextChatMessage)
	return properties
end

TextChatService.OnBubbleAdded = function(message)
	if not message.TextSource then
		return
	end
	local player = main.players:GetPlayerByUserId(message.TextSource.UserId)
	if not player then
		return
	end

	-- This modifies the bubble
	local properties = Instance.new("BubbleChatMessageProperties")
	local bubbleTextColor = player:GetAttribute("BubbleTextColor")
	if bubbleTextColor then
		properties.TextColor3 = bubbleTextColor
	end
	local bubbleBackgroundColor = player:GetAttribute("BubbleBackgroundColor")
	if bubbleBackgroundColor then
		properties.BackgroundColor3 = bubbleBackgroundColor
	end

	return properties
end
--]]


return ChatController