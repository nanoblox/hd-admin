--[[
	MainModule Summary:
	This module serves as the core of HD Admin's framework. It was designed with the goals of:
	1. Fully supporting typed-luau and auto-completion
	2. Modularized components to provide flexibility and customization over what runs within the experience.
	   For example, if you don't want to install 'Admin' commands, this is now possible because its container
	   of server and client command data is separated from the rest of the application.
	3. Future compatibility for Parallel Luau to enhance performance

	Framework Overview:
	- Services and Controllers are initialized instantly on start, whereas Modules are loaded on demand.
	- By default, everything under MainModule is categorized as "Client" and accessible across both the
	  client and server.
	- If a "Server" tag is applied to an instance, all its descendants are moved to the server environment, 
	  unless a descendant instance is tagged as "Client". In such cases, everything below the "Client" tag 
	  reverts to being shared between the client and server.
	- Server instances (such as scripts and data) are moved before initialization, so are never
	  accessible or replicated to the client.
]]


local Framework = {}
local APPLICATION_NAME = "HD Admin"
local appNameClean = APPLICATION_NAME:gsub(" ", "") -- Removes spaces
local hasStarted = false
local sharedMainModule = script:FindFirstAncestor("MainModule")
local sharedValue = sharedMainModule.Value

local function convertViewportToFolder(instance: Instance?)
	-- We use ViewportFrames initially as containers as they 'hide' descendant
	-- instances when HD Admin is stored in Workspace. This is desirable as it prevents
	-- clutter when installed via the toolbox, as models are by default added to Workspace.
	-- This however is not desirable at runtime due to performance impacts (see:
	-- https://devforum.roblox.com/t/worldmodels-too-costly-due-to-running-in-serial/3952084)
	-- so we destroy these ViewportFrames and replace them with Folders.
	if instance and instance:IsA("ViewportFrame") then
		local model = Instance.new("Model") -- Must be a model not folder to ensure everything is moved to server
		model.Name = instance.Name
		for _, child in instance:GetChildren() do
			child.Parent = model
		end
		model.Parent = instance.Parent
		instance:Destroy()
		return model
	end
	return nil
end

Framework.applicationName = APPLICATION_NAME
Framework.appNameClean = appNameClean
Framework.serverName = APPLICATION_NAME--`{appNameClean}Server`
Framework.serverLocation = "ServerStorage"
Framework.sharedName = APPLICATION_NAME--`{appNameClean}Shared`
Framework.sharedLocation = "ReplicatedStorage"

function Framework.initialize(loader)
	-- To do:
	-- 1. Check no other MainModule exists
	-- 2. Perform AutomaticUpdate

	-- This ensures HD Admin hasn't already been initialized, for example, if there
	-- are two applications running in the same game
	local hasLoaded = script:FindFirstChild("HasLoaded")
	if hasLoaded then
		return false
	end
	hasLoaded = Instance.new("ObjectValue")
	hasLoaded.Value = loader
	hasLoaded.Name = "HasLoaded"
	hasLoaded.Parent = script

	-- This now loads the server
	Framework.startServer()

	return true
end

function Framework.getLoader()
	local hasLoaded = script:FindFirstChild("HasLoaded")
	if not hasLoaded then
		return nil
	end
	return hasLoaded.Value
end

function Framework.getSharedContainer(): Instance?
	local sharedService = game:GetService(Framework.sharedLocation)
	local sharedContainer = sharedService:FindFirstChild(Framework.sharedName)
	return sharedContainer
end

function Framework.getServerContainer(): Instance?
	local serverService = game:GetService(Framework.serverLocation)
	local serverContainer = serverService:FindFirstChild(Framework.serverName)
	return serverContainer
end

function Framework.getInstance(container: Folder | ModuleScript, instanceName: string): Instance?
	--[[
		In most cases instances can be rerieved by just doing ``script[INSTANCE_NAME]``,
		however, when the *server* wants to access a model, indexing
		the instance can return nil or throw an error, because it's possible for the instance to be located in the
		both mirrored shared container and server container. This is the same still even when doing...
		```
		local sharedValue = script:FindFirstAncestor("MainModule").Value
		local model = sharedValue.Controllers.ModuleWithAnInstance[INSTANCE_NAME]
		```
		... because that model is still being referenced within a mirrored-mock Controller
		container within ServerStorage instead of its real one in ReplicatedStorage.

		Framework.getInstance(container, instanceName) overcomes this by checking for the asset first
		in ServerStorage, then ReplicatedStorage. It also checks for descendants until it reaches a
		non-ModuleScript or non-Folder instance.
	--]]
	if not container or not container:IsA("Instance") then
		return nil
	end
	local instance = container:FindFirstChild(instanceName)
	if instance then
		return instance
	end
	local RunService = game:GetService("RunService")
	if RunService:IsClient() then
		return nil
	end
	local sharedContainer = Framework.getSharedContainer()
	if not sharedContainer then
		return nil
	end
	local parents = {}
	local part = container
	local serverContainer = Framework.getServerContainer()
	if not serverContainer then
		return nil
	end
	for i = 1, 100 do
		table.insert(parents, part.Name)
		part = part.Parent
		if part == nil or part == serverContainer or part == sharedContainer then
			break
		end
	end
	local oppositeTopLevelContainer = sharedContainer
	if part == sharedContainer then
		oppositeTopLevelContainer = serverContainer
	end
	local function getNextPart(containerToCheck)
		local nextPart = containerToCheck
		for i = #parents, 1, -1 do
			nextPart = nextPart:FindFirstChild(parents[i])
			if not nextPart then
				return nil
			end
		end
		return nextPart
	end
	local nextPart = getNextPart(oppositeTopLevelContainer)
	local function checkChildren(instanceToCheck)
		if not instanceToCheck or not instanceToCheck:IsA("Instance") then
			return nil
		end
		local foundInstance = instanceToCheck:FindFirstChild(instanceName)
		if foundInstance then
			return foundInstance
		end
		for _, child in instanceToCheck:GetChildren() do
			if child:IsA("ModuleScript") or child:IsA("Folder") or child:IsA("Configuration") then
				foundInstance = checkChildren(child)
				if foundInstance then
					return foundInstance
				end
			end
		end
		return nil
	end
	return checkChildren(nextPart)
end

function Framework.canStart()
	if hasStarted then
		return false, "Framework has already started"
	end
	local hasLoaded = script:WaitForChild("HasLoaded", 999)
	if hasLoaded.Value == false then
		return false, "Another HD Admin was initialized"
	end
	hasStarted = true
	return true
end

function Framework.requireChildren(container: Instance)
	for _, child in container:GetChildren() do
		if child:IsA("ModuleScript") then
			task.spawn(require, child)
		end
	end
end

function Framework.startClient()
	-- Only setup if not started already
	local value = script:FindFirstAncestor("MainModule").Value
	if Framework.canStart() == false then
		return
	end

	-- Destroy all instances with the attribute 'HDAdminServerOnly'
	-- This is simply for easier browning in Studio because these modules/folders are already
	-- hollow (placeholders) and don't actually contain any data
	local function destroyServerOnlyInstances(instance: Instance)
		for _, child in instance:GetChildren() do
			if child:GetAttribute("ServerOnly") and child:GetAttribute("HasSharedDescendant") ~= true then
				child:Destroy()
			else
				destroyServerOnlyInstances(child)
			end
		end
	end
	destroyServerOnlyInstances(value)

	-- Start Controllers
	Framework.requireChildren(sharedValue.Controllers)
end

function Framework.startServer()
	-- Only setup if not started already
	if Framework.canStart() == false then
		return
	end
	
	-- Convert Viewports to Folders
	local modules = sharedValue.Modules
	local loader = Framework.getLoader()
	local loaderConfig = loader:FindFirstChild("Config")
	sharedValue = convertViewportToFolder(sharedValue)
	if loaderConfig then
		for _, child in loaderConfig:GetChildren() do
			convertViewportToFolder(child)
		end
	end

	-- These are the containers in which the Server and Shared sit
	local function createContainer(containerName: string, location: any): Folder
		local container = Instance.new("Folder")
		local service = game:GetService(location)
		for _, child in service:GetChildren() do
			if child.Name == containerName then
				-- This is just incase the user places the loader in ReplicatedStorage
				-- or ServerStorage which would have an identical conflicting name
				child.Parent = nil
			end
		end
		container.Name = containerName
		container.Parent = service
		local fakeCore = Instance.new("Folder")
		fakeCore.Name = "Core"
		fakeCore.Parent = container
		local fakeConfig = Instance.new("Folder")
		fakeConfig.Name = "Config"
		fakeConfig.Parent = container
		return container
	end

	-- This is the faux server MainModule
	local serverContainer = createContainer(Framework.serverName, Framework.serverLocation)
	local serverMainModule = Instance.new("ObjectValue")
	serverMainModule.Name = sharedMainModule.Name
	serverMainModule.Value = sharedValue
	serverMainModule.Parent = serverContainer.Core

	-- This is the primary client container
	-- It's important we create this before merging Config items as 'Accessible'
	-- items depend on it
	local clientContainer = createContainer(Framework.sharedName, Framework.sharedLocation)

	-- This handles the moving of 'ReferenceBackConfig' modules for items labelled
	-- as 'Accessible' in Config, so that they can be referenced on both client and
	-- server, *and* from within and outside of the Loader Config
	-- It's important to perform this first otherwise some modules like CustomArgs
	-- won't be findable
	local framework = modules.Framework
	local moduleReference = framework.ModuleReference
	local referenceBack = framework.ReferenceBack
	local referenceBackConfig = framework.ReferenceBackConfig
	local emptyFunction = framework.EmptyFunction
	local coreConfig = modules.Parent.Services.Config
	local CoreConfig = require(coreConfig) --loaderConfig
	for moduleName, _ in CoreConfig.getAccessible() do
		local loaderModule = loaderConfig and loaderConfig:FindFirstChild(moduleName)
		local serverConfig = serverContainer.Config
		local sharedConfig = clientContainer.Config
		local referenceBackServer = referenceBackConfig:Clone()
		local referenceBackShared = referenceBackConfig:Clone()
		referenceBackServer.Name = moduleName
		referenceBackShared.Name = moduleName
		referenceBackServer.Parent = serverConfig
		referenceBackShared.Parent = sharedConfig
		if not loaderModule then
			loaderModule = emptyFunction:Clone()
			loaderModule.Name = moduleName
			loaderModule.Parent = loaderConfig or coreConfig -- Doesn't matter which on, will still end up in same place
		end
		loaderModule:SetAttribute("Client", true)
	end

	-- First move Loader Commands from under Config Roles to under the Commands service
	-- We do this to prevent long pathways being created, and to avoid any merging
	-- confusions which can occur from the modules being located under Configuration instances
	local configRoles = loaderConfig and loaderConfig:FindFirstChild("Roles")
	if configRoles then
		local deepCopyTable = require(modules.TableUtil.deepCopyTable)
		local forEveryCommand = require(modules.CommandUtil.forEveryCommand)
		local function checkForRolesAndCommands(instanceToCheck, rolesArray)
			for _, roleConfigOrModule in instanceToCheck:GetChildren() do
				if roleConfigOrModule:IsA("Configuration") then
					local newRolesArray = deepCopyTable(rolesArray)
					local role = roleConfigOrModule.Name
					table.insert(newRolesArray, role)
					checkForRolesAndCommands(roleConfigOrModule, newRolesArray)
					continue
				end
				if not roleConfigOrModule:IsA("ModuleScript") then
					continue
				end
				--
				local rolesString = table.concat(rolesArray, " ||| ")
				roleConfigOrModule:SetAttribute("RolesToAdd", rolesString)
				--
				roleConfigOrModule:SetAttribute("PrimaryRole", true)
				for _, child in roleConfigOrModule:GetChildren() do
					-- We set a 'Child' attribute for all child modules named 'Client'
					-- in case the creator of the command forgets to tag the module
					-- with the 'Client' attribute (which exposes the instance to the client)
					if not child:IsA("ModuleScript") then
						continue
					end
					if child.Name:lower() ~= "client" then
						continue
					end
					child:SetAttribute("Client", true)
				end
				roleConfigOrModule.Parent = sharedValue.Services.Commands
			end
		end
		checkForRolesAndCommands(configRoles, {})
	end
	
	-- Merge Loader Config items into the core
	if loaderConfig then
		for _, child in loaderConfig:GetChildren() do
			local moduleName = child.Name
			local existingInstance = coreConfig:FindFirstChild(moduleName)
			if child:IsA("ModuleScript") and existingInstance then
				local originalSettings = require(existingInstance) :: any
				local newSettings = require(child) :: any
				local function mergeTablesRecursively(original, new)
					for key, value in new do
						if type(value) == "table" and type(original[key]) == "table" then
							mergeTablesRecursively(original[key], value)
						else
							original[key] = value
						end
					end
				end
				mergeTablesRecursively(originalSettings, newSettings)
				continue
			end
			if existingInstance then
				existingInstance:Destroy()
			end
			child.Parent = coreConfig
		end
		loaderConfig:Destroy()
	end

	-- These functions build the directories within server and shared
	local function getServerParentFromPathway(pathway)
		local serverParent = serverMainModule
		local sharedParent = sharedMainModule
		local sharedInstance: Instance? = nil
		local highestTaggedIndex = 0
		local nextInstance = sharedParent
		for i, instanceToCheck in pathway do
			nextInstance = nextInstance:FindFirstChild(instanceToCheck.Name)
			if not nextInstance then
				break
			end
			if nextInstance:GetAttribute("Server") == true and nextInstance:IsA("ModuleScript") then
				highestTaggedIndex = i
			end
		end
		local totalPathway = #pathway
		for i, instance in pathway do
			sharedInstance = sharedParent:FindFirstChild(instance.Name)
			if not sharedInstance then
				break
			end
			local serverInstance = serverParent:FindFirstChild(sharedInstance.Name)
			if not serverInstance then
				
				local sharedInstanceIsModule = sharedInstance:IsA("ModuleScript")
				local hasSharedDescendant = sharedInstance:GetAttribute("HasSharedDescendant")
				if i >= highestTaggedIndex and i ~= totalPathway then
					-- If no descendants contain Server tags, simply move
					-- the entire container as soon as possible
					serverInstance = sharedInstance
					sharedInstance = nil

				elseif sharedInstanceIsModule and sharedInstance:GetAttribute("Server") == true and sharedInstance:GetAttribute("Client") ~= true then
					-- We move the real item to the server, then leave an empty
					-- module behind in its place so that Type Checking still works
					local moduleReferenceCopy = moduleReference:Clone()
					moduleReferenceCopy:SetAttribute("HasSharedDescendant", hasSharedDescendant)
					moduleReferenceCopy:SetAttribute("ServerOnly", true)
					moduleReferenceCopy.Name = sharedInstance.Name
					moduleReferenceCopy.Parent = sharedParent
					for _, child in sharedInstance:GetChildren() do
						if child:IsA("ModuleScript") or child:IsA("Folder") or child:IsA("Configuration") then
							child.Parent = moduleReferenceCopy
						end
					end
					serverInstance = sharedInstance
					sharedInstance = moduleReferenceCopy
				elseif sharedInstanceIsModule then
					local referenceBackCopy = referenceBack:Clone()
					referenceBackCopy:SetAttribute("HasSharedDescendant", hasSharedDescendant)
					referenceBackCopy.Name = sharedInstance.Name
					referenceBackCopy.Parent = sharedParent
					serverInstance = referenceBackCopy
				else
					serverInstance = Instance.new("Folder")
					serverInstance.Name = sharedInstance.Name
				end
				serverInstance.Parent = serverParent
			end
			serverParent = serverInstance
			sharedParent = sharedInstance
			if not sharedParent then
				break
			end
		end
		return serverParent
	end

	local deepCopyTable = require(modules.TableUtil.deepCopyTable)
	local function setNewParentFromPathway(child, pathway)
		local newPathway = deepCopyTable(pathway)
		table.insert(newPathway, child)
		getServerParentFromPathway(newPathway)
	end

	-- We move relevant modules and services to the server, but we leave
	-- behind a module reference so that they are still required correctly
	local function checkToMoveChildren(parentsharedInstance, pathway, forceToServer)
		local newPathway = deepCopyTable(pathway)
		table.insert(newPathway, parentsharedInstance)
		for _, child in parentsharedInstance:GetChildren() do
			if not child:IsA("ModuleScript") and not child:IsA("Folder") and not child:IsA("Configuration") then
				continue
			end
			local hasServerTag = child:GetAttribute("Server") == true
			local childForceToServer = forceToServer
			if not childForceToServer then
				childForceToServer = hasServerTag
			end
			local hasSharedTag = child:GetAttribute("Client") == true
			if hasSharedTag then
				childForceToServer = nil
				local parentToCheck = child
				for i = 1, 100 do
					-- This tags modules above so that they are not destroyed on the client
					parentToCheck = parentToCheck.Parent
					if not parentToCheck or parentToCheck.Name == "Modules" then
						break
					end
					if parentToCheck and parentToCheck:GetAttribute("HasSharedDescendant") ~= true then
						parentToCheck:SetAttribute("HasSharedDescendant", true)
					end
				end
			end
			if childForceToServer and not hasServerTag then
				child:SetAttribute("Server", true)
			end
			checkToMoveChildren(child, newPathway, childForceToServer)
			if childForceToServer then
				setNewParentFromPathway(child, newPathway)
			end
		end
	end
	checkToMoveChildren(sharedValue, {})
	
	-- It's important we do this after moving the modules above, so that
	-- the client only has access to modules that they need to access
	sharedMainModule.Parent = clientContainer.Core
	
	-- Start Services
	Framework.requireChildren(sharedValue.Services)
end

return Framework