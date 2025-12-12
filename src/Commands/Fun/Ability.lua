--!strict
local ORDER = 50
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
type Command = Task.Command

return {

    --------------------
	loadCommand("Spin", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("ForceField", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Fire", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Smoke", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Sparkles", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Sit", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("NightVision", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Respawn", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Jump", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Warp", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Blur", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Freeze", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Name", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("HideName", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Reset", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------

}