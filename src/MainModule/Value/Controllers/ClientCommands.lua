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
	local clientCommand = ClientCommands.getCommand(properties.commandKey)
	local activeTask = Task.getTask(properties.UID)
	if not clientCommand then
		return
	end
	if activeTask then
		activeTask.clientArgs = properties.clientArgs
		activeTask:run()
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

Remote.get("ReplicateClientCommand"):onClientEvent(function(commandKey:string, ...)
	local clientCommand = ClientCommands.getCommand(commandKey)
	if clientCommand and typeof(clientCommand.replication) == "function" then
		(clientCommand.replication :: any)(...)
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
	local function scanContainerForClientCommands(container: Instance, requiresActiveModule: boolean?)
		for _, commandModule in container:GetChildren() do
			if not commandModule:IsA("ModuleScript") then
				if commandModule:IsA("Folder") then
					scanContainerForClientCommands(commandModule, requiresActiveModule)
				end
				continue
			end
			if requiresActiveModule == true and not commandModule:GetAttribute("IsActive") then
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
	end
	scanContainerForClientCommands(modules.Internal, true)
	scanContainerForClientCommands(services.Commands)
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