--!strict
-- LOCAL
local ClientCommands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Task = require(modules.Objects.Task)
local clientCommandsArray: Task.ClientCommands = {}
local lowerCaseNameDictionary: {[string]: ClientCommand} = {}
local commandsRequireUpdating = true
local Remote = require(modules.Objects.Remote)


-- TYPES
type Task = Task.Class
type ClientCommand = Task.ClientCommand
type ClientCommands = Task.ClientCommands


-- NETOWORKING
Remote.get("RunClientCommand"):onClientEvent(function(properties: Task.Properties, ...)
	print("RECEIVED:", properties, ...)
	local clientCommand = ClientCommands.getCommand(properties.commandName)
	local activeTask = Task.getTask(properties.UID)
	if not clientCommand or activeTask then
		return
	end
	local task = Task.new(properties)
	task:keep("Indefinitely") -- We keep client tasks until their server one ends
end)

Remote.get("EndClientTask"):onClientEvent(function(taskUID: string)
	local activeTask = Task.getTask(taskUID)
	if activeTask then
		activeTask:destroy()
	end
end)

Remote.get("ReplicateClientCommand"):onClientEvent(function(commandName:string, ...)
	local clientCommand = ClientCommands.getCommand(commandName)
	local replicate = clientCommand and clientCommand.replicate
	if typeof(replicate) == "function" then
		replicate(...)
	end
end)


-- FUNCTIONS
function ClientCommands.updateCommands()
	if not commandsRequireUpdating then
		return false
	end
	commandsRequireUpdating = false
	clientCommandsArray = {}
	lowerCaseNameDictionary = {}
	local forEveryCommand = require(modules.CommandUtil.forEveryCommand)
	for _, commandModule in services.Commands:GetChildren() do
		if not commandModule:IsA("ModuleScript") then
			continue
		end
		for _, clientCommandModule in commandModule:GetChildren() do
			if not clientCommandModule:IsA("ModuleScript") then
				continue
			end
			if clientCommandModule.Name:lower() ~= "client" then
				continue
			end
			local commandsInside = require(clientCommandModule) :: any
			forEveryCommand(commandsInside, function(command: any)
				table.insert(clientCommandsArray, command :: ClientCommand)
				lowerCaseNameDictionary[command.name:lower()] = command :: ClientCommand
			end)
		end
	end
	return true
end

function ClientCommands.getCommand(name: string): ClientCommand?
	ClientCommands.updateCommands()
	local lowerName = name:lower()
	local command = lowerCaseNameDictionary[lowerName] :: ClientCommand?
	return command
end

function ClientCommands.getCommandsArray()
	ClientCommands.updateCommands()
	return clientCommandsArray
end


return ClientCommands