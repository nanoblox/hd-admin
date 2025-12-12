--!strict
local ORDER = 30
local ROLES = {script.Parent.Name, "Bundle"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Bundle", function(command)
	command.order = ORDER
	command.roles = ROLES
end)