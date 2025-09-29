--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local commands: Task.Commands = {

    --------------------
	{
		name = "fly",
		aliases = {},
		args = {"Player", "Speed"},
		run = function(task: Task.Class, args)
			task:keep("UntilTargetRespawns")
			task.client:run(task.target, "HOLA AMIGO")
			task.client.replicator = function(replicateTo, ...)
				local getTargets = require(modules.PlayerUtil.getTargets)
				for _, player in getTargets("All") do
					replicateTo(player, ...)
				end
			end
		end
	},
	
    --------------------
}
return commands