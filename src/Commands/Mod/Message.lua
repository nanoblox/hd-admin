--!strict
local ORDER = 200
local ROLES = {script.Parent.Name, "Message"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local commands = Internal.loadCommandGroup("Message", function(command)
	command.order = ORDER
	command.roles = ROLES
end)
return commands