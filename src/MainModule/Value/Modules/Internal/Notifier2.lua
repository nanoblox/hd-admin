--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Players = game:GetService("Players")
local Task = require(modules.Objects.Task)
local Prompt = require(modules.Prompt)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local runPromptCommand = require(modules.CommandUtil.runPromptCommand)
local Prompt = require(modules.Prompt)


-- LOCAL FUNCTIONS
local function runCountdownCommand(promptType: Prompt.PromptType, task: Task.Class, args: {any})
	local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
	local color = task:getOriginalArg("OptionalColor")
	local integer = args[3]
	for i = integer, 1, -1 do
		local delayTime = integer - i
		local text = tostring(i)
		task.delay(delayTime, function()
			for _, target in targets do
				local prompt = (Prompt :: any)[promptType]
				task.janitor:add(prompt(target, text, {
					fromUserId = task.callerUserId,
					color = color,
					duration = 1,
				}))
			end
		end)
	end
	task.wait(integer)
end


-- COMMANDS
local commands: Task.Commands = {

	-------------------- 
	{
		name = "PrivateMessage",
		aliases = {"PM"},
		args = {"Player", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, text = unpack(args)
			Prompt.privateMessage(target, text, {
				fromUserId = task.callerUserId,
			})
		end
	},

    --------------------
	{
		name = "ServerMessage",
		aliases	= {"SM", "SMessage"},
		args = {"OptionalPlayers", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local color = task:getOriginalArg("OptionalColor")
			local text = args[3]
			runPromptCommand("message", task, targets, text, {
				fromUserName = "System",
				color = color,
			})
		end
	},

    --------------------
	{
		name = "ServerHint",
		aliases	= {"SH", "SHint"},
		args = {"OptionalPlayers", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local color = task:getOriginalArg("OptionalColor")
			local text = args[3]
			runPromptCommand("hint", task, targets, text, {
				fromUserName = "System",
				color = color,
			})
		end
	},

    --------------------
	{
		name = "Countdown",
		aliases = {"CountdownHint", "Countdown1"},
		args = {"OptionalPlayers", "OptionalColor", "CountdownTime"},
		run = function(task: Task.Class, args: {any})
			runCountdownCommand("hint", task, args)
		end
	},

    --------------------
	{
		name = "Countdown2",
		aliases = {"CountdownMessage"},
		args = {"OptionalPlayers", "OptionalColor", "Number"},
		run = function(task: Task.Class, args: {any})
			runCountdownCommand("message", task, args)
		end
	},

    --------------------
	{
		name = "Alert",
		aliases = {"Warn"},
		args = {"OptionalPlayers", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local text = args[2]
			for _, target in targets do
				Prompt.alert(target, text, {
					fromUserId = task.callerUserId,
				})
			end
		end
	},

    --------------------
	{
		name = "Vote",
		aliases = {"Poll"},
		autoPreview = true,
		args = {"OptionalPlayers", "Text", "Fields"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local text = args[2]
			local fields = args[3]
			local VOTING_DURATION = 20
			for _, target in targets do
				Prompt.vote(target, text, {
					title = text,
					fields = fields,
					fromUserId = task.callerUserId,
				})
			end
			task.wait(VOTING_DURATION)
		end
	},
	
    --------------------
	
}
return commands