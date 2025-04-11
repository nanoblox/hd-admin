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
		if nextInstance:HasTag("Server") and nextInstance:IsA("ModuleScript") then
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
			if i >= highestTaggedIndex and i ~= totalPathway then
				-- If no descendants contain Server tags, simply move
				-- the entire container as soon as possible
				serverInstance = sharedInstance
				sharedInstance = nil

			elseif sharedInstanceIsModule and sharedInstance:HasTag("Server") and not sharedInstance:HasTag("Shared") then
				-- We move the real item to the server, then leave an empty
				-- module behind in its place so that Type Checking still works
				local moduleReferenceCopy = moduleReference:Clone()
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
		local hasServerTag = child:HasTag("Server")
		local childForceToServer = forceToServer
		if not childForceToServer then
			childForceToServer = hasServerTag
		end
		local hasSharedTag = child:HasTag("Shared")
		if hasSharedTag then
			childForceToServer = nil
		end
		if childForceToServer and not hasServerTag then
			child:AddTag("Server")
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

print("Server setup!")