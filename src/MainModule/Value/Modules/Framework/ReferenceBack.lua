--!nocheck
-- This is for modules located on the server which need to reference back to shared module.
local main = script:FindFirstAncestor("MainModule")
local modules = main.Value.Modules
local Framework = require(modules.Framework)
local moduleName = script.Name
local modulePath = {moduleName}
local nextParent = script.Parent
while true do
	table.insert(modulePath, 1, nextParent.Name)
	nextParent = nextParent.Parent
	if not nextParent or nextParent == main then
		break
	end
end
local sharedLocation = Framework.sharedLocation
local sharedName = Framework.sharedName
local location = game:GetService(sharedLocation)
local container = location:WaitForChild(sharedName, 999)
local newMain = container.MainModule
local ourNewModule = newMain
for _, instanceName in modulePath do
	ourNewModule = ourNewModule:WaitForChild(instanceName, 999)
end
return require(ourNewModule)