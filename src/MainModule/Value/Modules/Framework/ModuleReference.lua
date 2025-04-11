--!nocheck
local RunService = game:GetService("RunService")
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Framework = require(modules.Framework)
local moduleName = script.Name
if RunService:IsClient() then
    error(`'{moduleName}' can only be accessed on the server! This was moved to the server by {Framework.applicationName} before replication because it contained the tag (Instance.Tags) 'Server'.`)
end
local modulePath = {moduleName}
local nextParent = script.Parent
while true do
	table.insert(modulePath, 1, nextParent.Name)
	nextParent = nextParent.Parent
	if not nextParent or nextParent == main then
		break
	end
end
local serverLocation = Framework.serverLocation
local serverName = Framework.serverName
local location = game:GetService(serverLocation)
local container = location:WaitForChild(serverName, 999)
local newMain = container.MainModule
local ourNewModule = newMain
for _, instanceName in modulePath do
	ourNewModule = ourNewModule:WaitForChild(instanceName, 999)
end
return require(ourNewModule)