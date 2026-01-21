--!strict
-- These are internal groups of commands
-- We 'internalize' a lot of commands so that they can continue to receive fixes
-- and updates/improvements while we build the separate HD Admin plugin to
-- help with automatic command updates. It's strongly recommended not to move an 
-- internal command to Config as these commands have long-term plans to be upgraded.

-- Important note: when Internal commands are referncing child instances (i.e. script.Child),
-- the child must be referenced at the top of the module (i.e. upon require), and not within
-- functions like run, as the child instances change location, whereas the original source
-- code does not.


-- LOCAL
local Internal = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Framework = require(modules.Framework)
local Task = require(modules.Objects.Task)
local internalCommandsLowercase: {[string]: any} = {}
local forEveryCommand = require(modules.CommandUtil.forEveryCommand)


-- LOCAL FUNCTIONS
local function reference()
	return {}
end


-- FUNCTIONS
function Internal.loadCommandGroup(moduleName: string, callback: ((command: any) -> ()))
	local serverModules = Framework.getServerModules() :: any
	if not serverModules then
		warn("HD Admin: loadCommands must be called from server")
		return {}
	end
	local commandsModule = serverModules.Internal:FindFirstChild(moduleName)
	if not commandsModule then
		warn("HD Admin: Internal Command '" .. moduleName .. "' not found")
		return {}
	end
	local commandsModuleShared = modules.Internal:FindFirstChild(moduleName)
	if not commandsModuleShared then
		warn("HD Admin: Internal Shared Command '" .. moduleName .. "' not found")
		return {}
	end
	local reference = require(commandsModule) :: any
	commandsModuleShared:SetAttribute("IsActive", true)
	if typeof(callback) ~= "function" then
		return reference
	end
	forEveryCommand(reference, function(command: any)
		callback(command)
	end)
	return reference :: Task.Commands
end

function Internal.loadCommand(groupName: string, commandName: string, callback: ((command: any) -> ())): any
	local commandsModuleShared = modules.Internal:FindFirstChild(groupName)
	if not commandsModuleShared then
		warn("HD Admin: Internal Command Module (Shared) '" .. groupName .. "' not found")
		return {}
	end
	local commandsModuleServer = modules.Internal:FindFirstChild(groupName)
	if not commandsModuleServer then
		warn("HD Admin: Internal Command Module (Server) '" .. groupName .. "' not found")
		return {}
	end
	local commandNameLower = string.lower(commandName)
	local commandInfo = internalCommandsLowercase[commandNameLower]
	if not commandInfo then
		local commands = require(commandsModuleServer) :: any
		forEveryCommand(commands, function(command: any)
			local newCommandInfo = {
				command = command,
				moduleName = groupName,
			}
			local newCommandNameLower = command.name:lower()
			internalCommandsLowercase[newCommandNameLower] = newCommandInfo
			if newCommandNameLower == commandNameLower then
				commandInfo = newCommandInfo
			end
		end)
	end
	if not commandInfo then
		warn("HD Admin: Internal Command '" .. commandName .. "' not found")
		return {}
	end
	local command = commandInfo.command
	commandsModuleShared:SetAttribute("IsActive", true)
	callback(command)
	return command :: Task.Command
end


return Internal