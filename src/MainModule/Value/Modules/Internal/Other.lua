--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local commands: Task.Commands = {

    --------------------
	{
		name = "Reset",
		aliases = {"Refresh", "Re"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local player: Player = unpack(args)
			local targetUserId = player.UserId
			local tasks = Task.getTasks(nil, targetUserId)
			for _, targetTask in tasks do
				targetTask:destroy()
			end
		end
	},

    --------------------
	{
		name = "Commands",
		aliases = {"Cmds"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			Prompt.info(target, "Coming Soon")
		end
	},

    --------------------
	
}
return commands