-- Useful for code which will be accessed by both server and client
local mainValue = script:FindFirstAncestor("MainModule").Value
local modules = mainValue.Modules
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()
return function(settingName: string)
	if isClient then
		local clientUser = require(modules.References.clientUser)
		local everyone = clientUser.everyone
		local success, value = everyone:fetchAsync("GameSettings", settingName)
		if not success then
			value = nil
		end
		return value
	end
	local services = mainValue.Services
	local config = require(services.Config)
	return config.getSetting(settingName)
end