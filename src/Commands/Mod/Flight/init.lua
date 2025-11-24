--!strict
local ORDER = 210
local ROLE = "Ability"
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Fly",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
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
	{
		name = "Fly2",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Noclip",
		undoAliases = {"Clip"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Noclip2",
		undoAliases = {"Clip2"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "AAAAAAA",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	
}
return commands