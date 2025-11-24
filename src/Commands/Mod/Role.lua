--!strict
local ORDER = 310
local ROLE = "Moderate"
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Role",
		aliases = {"GiveRole"},
		undoAliases = {"TakeRole"},
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
}
return commands