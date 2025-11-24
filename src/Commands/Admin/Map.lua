--!strict
local ORDER = 450
local ROLE = "Build"
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "SaveMap",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "LoadMap",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "LockMap",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "LockCharacter",
		aliases = {"LockChar", "LockPlayer"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "CreateTeam",
		undoAliases = {"RemoveTeam"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	
}
return commands