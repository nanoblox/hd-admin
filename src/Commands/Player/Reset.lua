--!strict
local ORDER = 90
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
type Command = Task.Command

return {

    --------------------
	loadCommand("Other", "Reset", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
	end),

    --------------------

}