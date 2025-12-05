-- These are internal groups of commands
-- We 'internalize' a lot of commands so that they can continue to receive fixes
-- and updates/improvements while we build the separate HD Admin plugin to
-- help with automatic command updates. It's strongly recommended not to move an 
-- internal command to Config as these commands have long-term plans to be upgraded.

local Internal = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules

function Internal.setupCommands(moduleName: string, callback: ((command: any) -> ()))
	local Task = require(modules.Objects.Task)
	local commandsModule = modules.Internal:FindFirstChild(moduleName)
	if not commandsModule then
		warn("HD Admin: Internal Command '" .. moduleName .. "' not found")
		return {}
	end
	local reference = require(commandsModule)
	if typeof(callback) ~= "function" then
		return reference
	end
	local forEveryCommand = require(modules.CommandUtil.forEveryCommand)
	forEveryCommand(reference, function(command: Task.Command)
		callback(command)
	end)
	return reference
end

return Internal