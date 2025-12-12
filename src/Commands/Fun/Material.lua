--!strict
local ORDER = 40
local ROLES = {script.Parent.Name, "Material"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Material", function(command)
	command.order = ORDER
	command.roles = ROLES
end)