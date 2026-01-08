--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	--[[{
		name = "Gears",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info("Coming soon!")
		end
	},--]]

    --------------------
	{
		name = "Gear",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info(task.caller, "Coming soon!")
		end
	},
	
    --------------------
	{
		name = "Sword",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.info("Coming soon!")
		end
	},

    --------------------
	
}
return commands