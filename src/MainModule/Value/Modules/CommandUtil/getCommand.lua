-- Useful for code which will be accessed by both server and client
local mainValue = script:FindFirstAncestor("MainModule").Value
local modules = mainValue.Modules
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
return function(commandName: string): any?
	if isClient then
		local clientUser = require(modules.References.clientUser)
		local everyone = clientUser.everyone
		local success, value = everyone:fetchAsync("CommandInfo", commandName)
		if success and typeof(value) == "table" then
			return value
		end
		return nil
	end
	local services = mainValue.Services
	local Commands = require(services.Commands)
	local command = Commands.getCommand(commandName)
	return command
end