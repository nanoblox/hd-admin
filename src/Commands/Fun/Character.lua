--!strict
local ORDER = 60
local ROLES = {script.Parent.Name, "Character"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Character", function(command)
	command.order = ORDER
	command.roles = ROLES
end)