--!strict
local ORDER = 400
local ROLES = {script.Parent.Name, "Chat"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Chat", function(command)
	command.order = ORDER
	command.roles = ROLES
end)