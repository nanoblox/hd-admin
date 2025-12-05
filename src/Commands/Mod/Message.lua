--!strict
local ORDER = 200
local ROLE = script.Name
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local commands = Internal.setupCommands(script.Name, function(command)
	command.order = ORDER
	command.roles = {ROLE}
end)
return commands