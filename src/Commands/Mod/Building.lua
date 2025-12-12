--!strict
local ORDER = 280
local ROLES = {script.Parent.Name, "Build"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
type Command = Task.Command

return {

    --------------------
	loadCommand("BuildingTools", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
	loadCommand("Clone", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------
}