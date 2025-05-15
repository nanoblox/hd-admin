--[[
	MainModule Summary:
	This module serves as the core of HD Admin's framework. It was designed with the goals of:
	1. Fully supporting typed-luau and auto-completion
	2. Modularized components to provide flexibility and customization over what runs within the experience.
	   For example, if you don't want to install 'Admin' commands, this is now possible because its container
	   of server and client command data is separated from the rest of the application.
	3. Future compatibility for Parallel Luau to enhance performance

	Framework Overview:
	- By default, everything under MainModule is categorized as "Shared" and accessible across both the
	  client and server.
	- If a "Server" tag is applied to an instance, all its descendants are moved to the server environment, 
	  unless a descendant instance is tagged as "Shared". In such cases, everything below the "Shared" tag 
	  reverts to being shared between the client and server.
	- Server instances (such as scripts and data) are moved before initialization, so are never
	  accessible or replicated to the client.
]]



local Framework = {}
local APPLICATION_NAME = "HD Admin"
local appNameClean = APPLICATION_NAME:gsub(" ", "") -- Removes spaces

Framework.applicationName = APPLICATION_NAME
Framework.appNameClean = appNameClean
Framework.serverName = `{appNameClean}Server`
Framework.serverLocation = "ServerStorage"
Framework.sharedName = `{appNameClean}Shared`
Framework.sharedLocation = "ReplicatedStorage"

function Framework.initialize(loader)
	-- To do:
	-- 1. Check no other MainModule exists
	-- 2. Perform AutomaticUpdate if Core folder Attribute is not enabled
	local hasLoaded = script:FindFirstChild("HasLoaded")
	if hasLoaded then
		return false
	end
	hasLoaded = Instance.new("ObjectValue")
	hasLoaded.Value = loader
	hasLoaded.Name = "HasLoaded"
	hasLoaded.Parent = script
	return true
end

function Framework.getLoader()
	local hasLoaded = script:FindFirstChild("HasLoaded")
	if not hasLoaded then
		return nil
	end
	return hasLoaded.Value
end

function Framework.startAsync()
	local hasLoaded = script:WaitForChild("HasLoaded", 999)
	if hasLoaded.Value == false then
		return false, "Another HD Admin was initialized"
	end
	return true
end

return Framework