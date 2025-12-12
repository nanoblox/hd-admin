--!strict
local ORDER = 310
local ROLES = {script.Parent.Name, "Moderate"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Role", function(command)
	command.order = ORDER
	command.roles = ROLES
end)