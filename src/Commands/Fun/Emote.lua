--!strict
local ORDER = 10
local ROLES = {script.Parent.Name, "Utility"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Emote", function(command)
	command.order = ORDER
	command.roles = ROLES
end)