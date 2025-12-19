--!strict
local ORDER = 410
local ROLES = {script.Parent.Name, "Prompt"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Notifier2", function(command)
	command.order = ORDER
	command.roles = ROLES
end)