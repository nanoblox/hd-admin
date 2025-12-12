--!strict
local ORDER = 410
local ROLES = {script.Parent.Name, "Message"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Prompt", function(command)
	command.order = ORDER
	command.roles = ROLES
end)