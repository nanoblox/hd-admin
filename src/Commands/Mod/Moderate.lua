--!strict
local ORDER = 290
local ROLES = {script.Parent.Name, "Moderate"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Moderate", function(command)
	command.order = ORDER
	command.roles = ROLES
end)