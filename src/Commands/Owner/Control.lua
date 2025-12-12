--!strict
local ORDER = 610
local ROLES = {script.Parent.Name, "Troll"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Control", function(command)
	command.order = ORDER
	command.roles = ROLES
end)