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
	loadCommand("Ability", "Spin", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "ForceField", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Fire", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Smoke", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Sparkles", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Sit", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "NightVision", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Respawn", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Jump", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Warp", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Blur", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Anchor", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "Name", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Ability", "HideName", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------

}