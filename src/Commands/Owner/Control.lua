--!strict
local ORDER = 610
local ROLE = script.Name
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.setupCommands(script.Name, function(command)
	command.order = ORDER
	command.roles = {ROLE}
end)