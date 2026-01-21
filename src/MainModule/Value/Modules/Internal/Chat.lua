--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local forceChatModule = modules.ChatUtil.forceChat


-- LOCAL FUNCTIONS
local function runChatCommand(realTask: Task.Class, startPrompt: string, endPrompt: string, properties: any)
	local target = realTask.target
	if not target then
		return
	end
	local forceChat = require(forceChatModule)
	for key, value in properties do
		target:SetAttribute(key, value)
	end
	target:SetAttribute("HDChatConfigEnabled", true)
	if target == realTask.caller then
		forceChat(target, startPrompt)
	end
	realTask:keep("UntilTargetLeaves")
	realTask:onEndedForGood(function()
		for key, value in properties do
			target:SetAttribute(key, nil)
		end
		if target ~= realTask.caller then
			return
		end
		forceChat(target, endPrompt)
	end)
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "ChatTag",
		aliases	= {"CTag"},
		args = {"Player", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, color, text = unpack(args)
			if task:getOriginalArg("OptionalColor") == nil then
				color = Color3.fromRGB(255, 85, 127)
			end
			if text == "" or text == " " then
				text = "ExampleTag"
			end
			runChatCommand(task, "Updated chat tag!", "Reset chat tag!", {
				ChatTag = text,
				ChatTagColor = color,
			})
		end
	},

    --------------------
	{
		name = "ChatTagColor",
		aliases	= {"TagColor"},
		args = {"Player", "Color"},
		run = function(task: Task.Class, args: {any})
			local target, color = unpack(args)
			if task:getOriginalArg("Color") == nil then
				color = Color3.fromRGB(255, 170, 127)
			end
			runChatCommand(task, "Updated chat tag color!", "Reset chat tag color!", {
				ChatTagColor = color,
			})
		end
	},

    --------------------
	{
		name = "ChatName",
		aliases	= {"CName"},
		args = {"Player", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, color, text = unpack(args)
			if task:getOriginalArg("OptionalColor") == nil then
				color = Color3.fromRGB(85, 255, 127)
			end
			if text == "" or text == " " then
				text = "ExampleName"
			end
			runChatCommand(task, "Updated chat name!", "Reset chat name!", {
				ChatName = text,
				ChatNameColor = color,
			})
		end
	},

    --------------------
	{
		name = "ChatNameColor",
		aliases	= {"NameColor"},
		args = {"Player", "Color"},
		run = function(task: Task.Class, args: {any})
			local target, color = unpack(args)
			if task:getOriginalArg("Color") == nil then
				color = Color3.fromRGB(130, 222, 255)
			end
			runChatCommand(task, "Updated chat name color!", "Reset chat name color!", {
				ChatNameColor = color,
			})
		end
	},
	
    --------------------
	{
		name = "BubbleChat",
		aliases	= {"BChat"},
		args = {"Player", "Text"},
		run = function(task: Task.Class, args: {any})
			local player, text = unpack(args)
			if text == "" or text == " " then
				text = "Example Bubble Message"
			end
			local character = player.Character
			if #text > 0 and character then
				local forceBubbleChat = require(modules.ChatUtil.forceBubbleChat)
				forceBubbleChat(player, character, text)
			end
		end
	},

    --------------------
	{
		name = "SystemMessage",
		aliases	= {"SystemChat", "SystemChat", "SC"},
		args = {"OptionalPlayer", "Text"},
		run = function(task: Task.Class, args: {any})
			local player, text = unpack(args)
			if text == "" or text == " " then
				text = "Example System Message"
			end
			if #text > 0 then
				local systemMessage = require(modules.ChatUtil.systemMessage)
				systemMessage(player, text)
			end
		end
	},

    --------------------
}


return commands