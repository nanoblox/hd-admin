--!strict
local ORDER = 20
local ROLES = {script.Parent.Name, "Troll"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
type Command = Task.Command

return {

    --------------------
	loadCommand("Ice", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Jail", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("LaserEyes", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Explode", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Fling", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
}