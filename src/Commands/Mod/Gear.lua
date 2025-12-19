--!strict
local ORDER = 240
local ROLES = {script.Parent.Name, "Fun"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Internal = require(modules.Internal)
local loadCommand = Internal.loadCommand
type Command = Task.Command

local commands: Task.Commands = {

    --------------------
	loadCommand("Gears", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	{
		name = "Gear",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Sword",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	
}
return commands