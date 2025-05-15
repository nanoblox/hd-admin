--!nocheck

-- Cancel run if another application has initialized
local sharedMainModule = script:FindFirstAncestor("MainModule")
local sharedValue = sharedMainModule.Value
local modules = sharedValue.Modules
local framework = modules.Framework
local moduleReference = framework.ModuleReference
local referenceBack = framework.ReferenceBack
local Framework = require(framework)
if Framework.startAsync() == false then
	return
end

-- Merge Loader Config items into the core
local loader = Framework.getLoader()
local loaderConfig = loader:FindFirstChild("Config")
local coreConfig = modules.Config
if loaderConfig then
	for _, child in loaderConfig:GetChildren() do
		local existingInstance = coreConfig:FindFirstChild(child.Name)
		if child:IsA("ModuleScript") and existingInstance then
			local originalSettings = require(existingInstance)
			local newSettings = require(child)
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
		else
			if existingInstance then
				existingInstance:Destroy()
			end
			child.Parent = coreConfig
		end
	end
	loaderConfig:Destroy()
end

-- These are the containers in which the Server and Shared sit
local function createContainer(containerName: string, location: any): Folder
	local container = Instance.new("Folder")
	container.Name = containerName
	container.Parent = game:GetService(location)
	return container
end

-- This is the faux server MainModule
local serverContainer = createContainer(Framework.serverName, Framework.serverLocation)
local serverMainModule = Instance.new("ObjectValue")
serverMainModule.Name = sharedMainModule.Name
serverMainModule.Value = sharedValue
serverMainModule.Parent = serverContainer

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

			elseif sharedInstanceIsModule and sharedInstance:GetAttribute("Server") == true and sharedInstance:GetAttribute("Shared") ~= true then
				-- We move the real item to the server, then leave an empty
				-- module behind in its place so that Type Checking still works
				local moduleReferenceCopy = moduleReference:Clone()
				moduleReferenceCopy:SetAttribute("HasSharedDescendant", hasSharedDescendant)
				moduleReferenceCopy:SetAttribute("ServerOnly", true)
				moduleReferenceCopy.Name = sharedInstance.Name
				moduleReferenceCopy.Parent = sharedParent
				for _, child in sharedInstance:GetChildren() do
					child.Parent = moduleReferenceCopy
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

local deepCopyTable = require(modules.Utility.TableUtil.deepCopyTable)
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
		local hasServerTag = child:GetAttribute("Server") == true
		local childForceToServer = forceToServer
		if not childForceToServer then
			childForceToServer = hasServerTag
		end
		local hasSharedTag = child:GetAttribute("Shared") == true
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
local clientContainer = createContainer(Framework.sharedName, Framework.sharedLocation)
sharedMainModule.Parent = clientContainer