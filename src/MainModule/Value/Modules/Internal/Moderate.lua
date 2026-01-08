--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Mute",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Kick",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Punish",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Warn",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			print("task.config =", task.config)
			Prompt.warn(task.caller, "Command Coming Soon")
		end
	},

    --------------------
	{
		name = "Follow",
		args = {"AnyUser"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	
}
return commands