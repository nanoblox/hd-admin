--!strict
local ORDER = 200
local ROLES = {script.Parent.Name, "Prompt"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Notifier1", function(command)
	command.order = ORDER
	command.roles = ROLES
end)