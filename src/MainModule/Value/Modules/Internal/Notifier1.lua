--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local runPromptCommand = require(modules.CommandUtil.runPromptCommand)
local Players = game:GetService("Players")
local commands: Task.Commands = {

	--------------------
	{
		name = "Hint",
		aliases = {"H"},
		args = {"OptionalPlayers", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local color = task:getOriginalArg("OptionalColor")
			local text = args[3]
			runPromptCommand("hint", task, targets, text, {
				fromUserId = task.callerUserId,
				color = color,
			})
		end
	},

    --------------------
	{
		name = "Message",
		aliases = {"M", "Announce", "Broadcast", "Announcement"},
		args = {"OptionalPlayers", "OptionalColor", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local color = task:getOriginalArg("OptionalColor")
			local text = args[3]
			runPromptCommand("message", task, targets, text, {
				fromUserId = task.callerUserId,
				color = color,
			})
		end
	},

    --------------------
	{
		name = "Notice",
		aliases = {"Not"}, -- Can't be called "N" as this conflicts with the "Un" modifier due to a current limitation with the parser
		args = {"OptionalPlayers", "Text"},
		run = function(task: Task.Class, args: {any})
			local targets = task:getOriginalArg("OptionalPlayers") or Players:GetPlayers()
			local text = args[2]
			runPromptCommand("info", task, targets, text, {
				fromUserId = task.callerUserId,
			})
		end
	},

    --------------------
	
}
return commands