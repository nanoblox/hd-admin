--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Role",
		aliases = {"GiveRole"},
		undoAliases = {"TakeRole"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			Prompt.info(target, "Coming Soon")
		end
	},

    --------------------
}
return commands