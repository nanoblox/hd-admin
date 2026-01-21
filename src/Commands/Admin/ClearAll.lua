--!strict
local ORDER = 490
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "ClearAll",
		aliases = {"ClrAll", "ResetAll"},
		roles = ROLES,
		order = ORDER,
		description = "Clears EVERY task, including those on targets",
		args = {"Caller"},
		run = function(task: Task.Class, args: {any})
			-- This clears all non-player specific tasks
			local callerToClear: Player = unpack(args)
			local tasks = Task.getTasks() :: {Task.Class}
			local Commands = require(modules.Parent.Services.Commands)
			for _, targetTask: Task.Class in tasks do
				if not targetTask.target then
					targetTask:destroy()
				end
			end
		end
	},

    --------------------
	
}


return commands