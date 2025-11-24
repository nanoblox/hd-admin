--!strict
local ORDER = 60
local ROLE = script.Name
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Ping",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "HideGuis",
		undoAliases = {"ShowGuis"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "ShowGuis",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Cmds",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	
}
return commands