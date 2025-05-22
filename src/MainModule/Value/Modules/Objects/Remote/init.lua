--!strict
-- LOCAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Janitor = require(modules.Objects.Janitor)
local Serializer = require(modules.Utility.Serializer)
local Remote = {}
local remotesContainerSaved = nil
local remotes = {}
Remote.__index = Remote


-- CONSTRUCTOR
function Remote.new(uniqueName: string, remoteType: RemoteType)

	-- Create remote instance if on server (else wait for it on client behind scenes)
	local janitor = Janitor.new()
	local remoteInstanceType = "RemoteEvent"
	local remoteInstance = nil

	-- Define properties
	local self = {
		janitor = janitor,
		uniqueName = uniqueName,
		permitInvokeCallback = true,
		remoteInstance = nil :: Instance?,
		isActive = true,
	}
	setmetatable(self, Remote)
	
	-- We create the remote instance on the server if it hasn't been created before
	if RunService:IsServer() then
		if remoteType == "Function" then
			remoteInstanceType = "RemoteFunction"
		elseif remoteType ~= "Event" and remoteType ~= nil then
			error("Invalid remoteType")
		end
		local remotesContainer = self:_getContainer() :: any
		if remotesContainer then
			if remotesContainer:FindFirstChild(uniqueName) then
				error(`Remote with name '{uniqueName}' already exists`)
			end
			remoteInstance = janitor:add(Instance.new(remoteInstanceType))
			remoteInstance.Name = uniqueName
			remoteInstance.Parent = remotesContainer
			self.remoteInstance = remoteInstance
		end
	end

	-- Register
	remotes[uniqueName] = self
	janitor:add(function()
		remotes[uniqueName] = nil
	end)

	
	return self
end

function Remote.get(uniqueName: string)
	-- The client alternative for .new
	-- It's preferable to do this on the client to account for server and client remotes
	-- evolving differently in the future
	-- The remoteType is ignored on the client, so we just fill it in with "Event"
	-- to pass type checking
	return Remote.new(uniqueName, "Event")
end

function Remote.find(existingRemoteName: string)
	return remotes[existingRemoteName]
end


-- CLASS
export type Class = typeof(Remote.new(...))
export type RemoteType = "Event" | "Function"
type Disconnect = {disconnect: (any?) -> ()}


-- METHODS
function Remote._getContainer(self: Class): Instance?
	if remotesContainerSaved then
		return remotesContainerSaved
	end
	local remotesContainerToGet = modules.Parent:FindFirstChild("Remotes")
	if RunService:IsServer() then
		if not remotesContainerToGet then
			remotesContainerToGet = Instance.new("Folder")
			remotesContainerToGet.Name = "Remotes"
			remotesContainerToGet.Parent = modules.Parent
		end
	else
		while self.isActive do
			remotesContainerToGet = modules.Parent:FindFirstChild("Remotes")
			if remotesContainerToGet then
				break
			end
			task.wait()
		end
	end
	if remotesContainerToGet then
		remotesContainerSaved = remotesContainerToGet :: any
	end
	return remotesContainerToGet
end

function Remote._createConnection(self: Class, disconnectCallback: () -> ()): Disconnect
	local connection = {}
	function connection.disconnect(connection: any?)
		disconnectCallback()
	end
	connection.Disconnect = connection.disconnect
	connection.Destroy = connection.disconnect
	return connection
end

function Remote._waitForInstance(self: Class): Instance?
	local remotesContainer = self:_getContainer()
	if not remotesContainer then
		return nil
	end
	while self.isActive do
		local instance = self.remoteInstance
		if instance == nil then
			instance = remotesContainer:FindFirstChild(self.uniqueName)
		end
		if instance then
			self.remoteInstance = instance
			return instance
		end
		task.wait()
	end
	return nil
end

function Remote._onInstanceLoaded(self: Class, callback)
	local remoteInstance = self.remoteInstance
	if remoteInstance then
		callback(remoteInstance)
		return
	end
	task.spawn(function()
		local remotesContainer = self:_getContainer()
		while remotesContainer and self.remoteInstance == nil and self.isActive do
			local instance = remotesContainer:FindFirstChild(self.uniqueName)
			if instance then
				self.remoteInstance = instance :: any
				break
			else
				task.wait()
			end
		end
		if self.remoteInstance then
			callback(self.remoteInstance)
		end
	end)
	return
end

function Remote.fireClient(self: Class, player: Player, ...)
	local remoteInstance = self.remoteInstance
	if not remoteInstance or not remoteInstance:IsA("RemoteEvent") then
		error("Can only call fireClient for remoteType 'Event'")
	elseif RunService:IsClient() then
		error("Can only call fireClient on server")
	elseif not player:IsA("Player") then
		error("Player must be a valid Player instance")
	end
	local packedData = table.pack(...)
	local compressedData = Serializer.processForNetwork(packedData)
	remoteInstance:FireClient(player, compressedData)
end

function Remote.fireAllClients(self: Class, ...)
	for _, player in pairs(Players:GetPlayers()) do
		self:fireClient(player, ...)
	end
end

function Remote.fireNearbyClients(self: Class, origin: Vector3, radius: number, ...)
	for _, player in pairs(Players:GetPlayers()) do
		if player:DistanceFromCharacter(origin) <= radius then
			self:fireClient(player, ...)
		end
	end
end

function Remote.fireServer(self: Class, ...)
	if RunService:IsServer() then
		error("Can only call fireServer on client")
	end
	local packedArgs = table.pack(...)
	self:_onInstanceLoaded(function(remoteInstance)
		if not remoteInstance:IsA("RemoteEvent") then
			error("Can only call fireServer for remoteType 'Event'")
		end
		remoteInstance:FireServer(table.unpack(packedArgs))
	end)
end

function Remote.invokeServerAsync(self: Class, ...): (boolean, ...any)
	if RunService:IsServer() then
		error("Can only call invokeServer on client")
	end
	local remoteInstance = self:_waitForInstance()
	if not remoteInstance then
		return false, "Remote was destroyed"
	elseif not remoteInstance:IsA("RemoteFunction") then
		return false, "Can only call invokeServer for remoteType 'Function'"
	end
	local packedArgs = table.pack(...)
	local success, returnedData = pcall(function()
		return remoteInstance:InvokeServer(table.unpack(packedArgs))
	end)
	if not success then
		return false, returnedData
	end
	local decompressedData = Serializer.processForNetwork(returnedData)
	return true, table.unpack(decompressedData)
end

function Remote.onClientEvent(self: Class, callback: (...any) -> ...any)
	if RunService:IsServer() then
		error("Can only call onClientEvent on client")
	end
	local realConnection = nil :: any
	self:_onInstanceLoaded(function(remoteInstance)
		if not remoteInstance:IsA("RemoteEvent") then
			error("Can only call onClientEvent for remoteType 'Event'")
		end
		if realConnection == false then
			return
		end
		realConnection = self.janitor:add(remoteInstance.OnClientEvent:Connect(function(compressedData)
			local decompressedData = Serializer.processForNetwork(compressedData)
			callback(table.unpack(decompressedData))
		end))
	end)
	return self:_createConnection(function()
		if realConnection then
			realConnection = realConnection :: any
			realConnection:Disconnect()
			realConnection = false
		end
	end)
end

function Remote.onServerEvent(self: Class, callback: (Player, ...any) -> ...any)
	local remoteInstance = self.remoteInstance
	if not remoteInstance or not remoteInstance:IsA("RemoteEvent") then
		error("Can only call onServerEvent for remoteType 'Event'")
	elseif RunService:IsClient() then
		error("Can only call onServerEvent on server")
	end
	local realConnection = self.janitor:add(remoteInstance.OnServerEvent:Connect(function(...)
		callback(...)
	end))
	return self:_createConnection(function()
		if realConnection then
			realConnection:Disconnect()
		end
	end)
end

function Remote.onServerInvoke(self: Class, callback: (Player, ...any) -> ...any)
	local remoteInstance = self.remoteInstance
	if not remoteInstance or not remoteInstance:IsA("RemoteFunction") then
		error("Can only call onServerInvoke for remoteType 'Function'")
	elseif RunService:IsClient() then
		error("Can only call onServerInvoke on server")
	elseif self.permitInvokeCallback ~= true then
		error("Can only have one onServerInvoke callback per remote")
	else
		self.permitInvokeCallback = false :: any
	end
	remoteInstance.OnServerInvoke = function(...)
		local packedData = table.pack(callback(...))
		local compressedData = Serializer.processForNetwork(packedData)
		return compressedData
	end
	self = self :: any
	return self:_createConnection(function()
		remoteInstance.OnServerInvoke = nil :: any
	end)
end

function Remote.destroy(self: Class)
	if self.isActive == false then
		return
	end
	self.isActive = false :: any
	self.janitor:destroy()
end


return Remote