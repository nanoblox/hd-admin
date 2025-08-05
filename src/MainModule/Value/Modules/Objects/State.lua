--[[

	This enhances the default behaviour of tables by providing additional functionality
	such as listeners, serialization and replication. This is especially useful for
	managing and tracking player data. When tables are set, they are deep copied. This
	means that all changes *must* be set with :set(), and that data returned with :get()
	will not be applied to the state if changed.

	The optional parameter to to create a serialized copy of data is particularly useful
	as it allows for data to be validated as soon as :set() is called, preventing any unsafe
	datastore data from ever reaching the datastore, and enabling the incorrect code to be
	flagged right away.

	Replication (which is enabled via state:replicate on the server and state:bind on the
	client) means that specified state data on the server can be synced and listened for via
	a state object on the client. State is only replicated to the client *once* the client
	requests it by doing :observe,:listen or :fetchAsync. Data does *not* replicate back
	to the server - this must be done separately.

]]


-- LOCAL
--!strict
local RunService = game:GetService("RunService")
local BINDING = "___"
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local deepCopyTable = require(modules.TableUtil.deepCopyTable)
local Serializer = require(modules.Serializer)
local Janitor = require(modules.Objects.Janitor)
local Players = game:GetService("Players")
local Remote = require(modules.Objects.Remote)
local stateReplication: Remote.Class?, stateReplicationRequest: Remote.Class? = nil, nil
local replicationHandlers = {}
local State = {}
State.__index = State


-- FUNCTIONS
function State.getPathwayKey(pathway: {any}): string
	local pathwayKey: string = ""
	for i, key in pathway do
		if typeof(key) ~= "string" then
			error("All arguments except final must be strings")
		end
		local binding = if i == 1 then "" else BINDING
		pathwayKey = pathwayKey..binding..key
	end
	return pathwayKey
end

function State.getPathway(pathwayKey: string): {string}
	local pathway = string.split(pathwayKey, BINDING)
	return pathway
end


-- CONSTRUCTOR
function State.new(dataMustBeSerializable: boolean?, initialTable: {[string]: any | number}?)
	
	-- Define properties
	local janitor = Janitor.new()
	local self = {
		_data = {} :: {[string]: any},
		_listeners = {} :: {[string]: {[number]: (...any) -> (...any)}},
		_changedCallbacks = {} :: {[number]: (...any) -> (...any)},
		_bindingReplicationKey = nil :: any?,
		_successfulBindings = {},
		_requestingBindings = {},
		janitor = janitor,
		dataMustBeSerializable = (if dataMustBeSerializable == true then true else false) :: boolean,
		isActive = true :: any,
	}

	-- Cleanup
	janitor:add(function()
		self._data = nil :: any
		self._listeners = nil :: any
	end)
	
	setmetatable(self, State)

	if initialTable then
		self:setAll(initialTable)
	end

	return self
end


-- CLASS
export type Class = typeof(State.new(...))
type Disconnect = {disconnect: (any?) -> ()}


-- METHODS
function State.get(self: Class, ...: string): any?
	-- Returns a deep copy of the data that was set
	local pathway = {...} :: {[number]: string}
	local value = self._data
	for _, key in pathway do
		value = value[key] :: any
		if value == nil then
			return nil
		end
	end
	if typeof(value) == "table" then
		return deepCopyTable(value)
	end
	return value
end

function State.getAll(self: Class, getSerialized: boolean?): {[string]: any}
	if getSerialized then
		local serializedCopy = Serializer.serialize(self._data, true)
		return serializedCopy
	end
	local normalCopy = deepCopyTable(self._data) :: {[string]: any}
	return normalCopy
end

function State.set(self: Class, ...: string | any)
	-- If the pathway does not exist, it is built automatically
	-- If the pathway does exist, but is not built up of tables, then an error is thrown
	if self.isActive ~= true then
		return
	end
	local totalArgs = select("#", ...)
	local finalArg = select(totalArgs, ...)
	local pathwayAndValue = {...}
	local value = finalArg
	if totalArgs == #pathwayAndValue then
		table.remove(pathwayAndValue, totalArgs)
	end
	if self.dataMustBeSerializable == true and not Serializer.isValid(value) then
		error(`State has 'dataMustBeSerializable' enabled, but the value '{tostring(value)}' (type: {typeof(value)}) is not serializable`)
	end
	local data = self._data
	local dataTable = data
	local pathway = {} :: {[number]: string}
	local callbacksToCall = {} :: {{(any) -> (any)}}
	local function buildPathway(keyToAdd: string, useGivenValue: boolean?)
		-- Every time the pathway develops, we check for listeners and call if present
		if typeof(keyToAdd) ~= "string" then
			error("Keys must be strings")
		end
		if string.match(keyToAdd, BINDING) then
			error(`Keys cannot contain '{BINDING}'`)
		end
		local dataValue = if useGivenValue then value else dataTable[keyToAdd]
		if dataValue == nil and value ~= nil then
			dataValue = {}
		end
		if not useGivenValue and typeof(dataValue) ~= "table" and typeof(value) ~= "table" then
			error("Cannot set a multi-pathway-key to a non-table that already exists")
		end
		dataTable[keyToAdd] = dataValue
		if typeof(dataValue) == "table" then
			dataTable = dataValue :: any
		end
		table.insert(pathway, keyToAdd)
		local pathwayKey = State.getPathwayKey(pathway)
		local callbacksArray = self._listeners[pathwayKey]
		if callbacksArray then
			for _, callback in callbacksArray do
				callback = callback :: (any) -> (any)
				table.insert(callbacksToCall, {callback, dataValue})
			end
		end
	end
	local function addValueTablesToPathwayRecursive(valueToCheck: any)
		-- This allows us to listen to changes within value (if present) in addition
		-- to the given pathway of the key
		if typeof(valueToCheck) == "table" then
			for subKey, subValue in (valueToCheck :: {[any]: any}) do
				if typeof(subKey) == "string" then
					buildPathway(subKey)
					addValueTablesToPathwayRecursive(subValue)
				end
			end
		end
	end
	local finalIndex = #pathwayAndValue
	for i, keyToAdd in pathwayAndValue do
		buildPathway(keyToAdd, i == finalIndex)
	end
	addValueTablesToPathwayRecursive(value)
	for _, callbackDetail in callbacksToCall do
		local callback = callbackDetail[1]
		local dataValue = callbackDetail[2]
		task.spawn(callback, dataValue)
	end
	local pathwayKey = State.getPathwayKey(pathway)
	for _, callback in self._changedCallbacks do
		task.spawn(callback, pathwayKey, value)
	end
end

function State.setAll(self: Class, table: {[string]: any}?)
	if table == nil then
		table = {}
	end
	table = table :: {[string]: any}
	if self.isActive ~= true then
		return
	end
	for key, value in table do
		self:set(key, value)
	end
	for key, value in self._data do
		if not table[key] then
			self:set(key, nil)
		end
	end
end

function State.update(self: Class, ...: string | any)
	-- This is the same as set, but the value is a function that returns the new value
	local totalArgs = select("#", ...)
	local finalArg = select(totalArgs, ...)
	local pathwayAndCallback = {...}
	local callback = finalArg
	if totalArgs == #pathwayAndCallback then
		table.remove(pathwayAndCallback, totalArgs)
	end
	if typeof(callback) ~= "function" then
		error("Final argument must be a function")
	end
	local currentValue = self:get(table.unpack(pathwayAndCallback))
	local newValue = callback(currentValue)
	self:set(table.unpack(pathwayAndCallback), newValue)
end

function State.changed(self: Class, callback: (pathwayKey: string, value: any) -> (...any))
	local callbacksArray = self._changedCallbacks
	table.insert(callbacksArray, callback)
	return self:_createConnection(function()
		if self.isActive ~= true then
			return
		end
		local index = table.find(callbacksArray, callback)
		if index then
			table.remove(callbacksArray, index)
		end
	end)
end

function State._createConnection(self: Class, disconnectCallback): Disconnect
	local connection = {}
	function connection.disconnect(connection: any?)
		disconnectCallback()
	end
	connection.Disconnect = connection.disconnect
	connection.Destroy = connection.disconnect
	return connection
end

function State.listen(self: Class, ...: string | (...any) -> (...any)): Disconnect
	local totalArgs = select("#", ...)
	local finalArg = select(totalArgs, ...)
	local pathwayAndCallback = {...}
	local callback = finalArg
	if typeof(callback) ~= "function" then
		error("Final argument must be a function")
	end
	if totalArgs == #pathwayAndCallback then
		table.remove(pathwayAndCallback, totalArgs)
	end
	local pathwayKey = State.getPathwayKey(pathwayAndCallback)
	local callbacksArray = self._listeners[pathwayKey]
	if not callbacksArray then
		callbacksArray = {}
		self._listeners[pathwayKey] = callbacksArray
	end
	table.insert(callbacksArray, callback :: any) 
	if self._bindingReplicationKey then
		task.spawn(function()
			self:fetchAsync(table.unpack(pathwayAndCallback :: {string}))
		end)
	end
	return self:_createConnection(function()
		if self.isActive ~= true then
			return
		end
		local index = table.find(callbacksArray, callback)
		if index then
			table.remove(callbacksArray, index)
		end
	end)
end

function State.observe(self: Class, ...: string | (...any) -> (...any)): {disconnect: (any?) -> ()}
	-- This is the same as listen, but the callback is called immediately with the current value
	local totalArgs = select("#", ...)
	local finalArg = select(totalArgs, ...)
	local pathway = {...}
	local callback = finalArg
	if typeof(callback) ~= "function" then
		error("Final argument must be a function")
	end
	if totalArgs == #pathway then
		table.remove(pathway, totalArgs)
	end
	local pathwayKey = State.getPathwayKey(pathway)
	local successfulBindings = self._successfulBindings :: {[string]: any}
	if self._bindingReplicationKey == nil or successfulBindings[pathwayKey] then
		task.spawn(callback, self:get(table.unpack(pathway)))
	end
	return self:listen(...)
end

function State.replicate(self: Class, player: Player, replicationName: string, pathwaysToLimitTo: {{string}}?)
	if RunService:IsServer() == false then
		error("State.replicate can only be called on the server")
	end
	if typeof(player) ~= "Instance" or player:IsA("Player") == false then
		error("First argument must be a player")
	end
	local userId = player.UserId
	local replicationKey = `{userId}_{replicationName}`
	local alreadyExists = replicationHandlers[replicationKey]
	if alreadyExists then
		error(`replicationKey '{replicationKey}' has already been used'`)
	end

	-- Remove key once replication ends (i.e. player leaves)
	local repJanitor = self.janitor:add(Janitor.new())
	repJanitor:add(function()
		replicationHandlers[replicationKey] = nil
	end)

	-- Invoke can only be called once so we set it up initially here then build the handler below
	if not stateReplication then
		stateReplication = Remote.new("StateReplication", "Event") :: any
		stateReplicationRequest = Remote.new("StateReplicationRequest", "Function")
		stateReplicationRequest:onServerInvoke(function(player, incomingReplicationKey: string, ...: unknown): (boolean, string | {any})
			if typeof(incomingReplicationKey) ~= "string" then
				return false, "Replication name must be a string"
			end
			local replicationHandler = replicationHandlers[incomingReplicationKey] :: (...any) -> (boolean, string | {any})?
			if not replicationHandler then
				return false, "Replication handler does not exist"
			end
			return replicationHandler(player, ...)
		end)
	end
	stateReplicationRequest = stateReplicationRequest :: Remote.Class
	local activeListeners = {}
	local activeListenersSize = 0
	repJanitor:add(function()
		for k, v in pairs(activeListeners) do
			activeListeners[k] = nil
		end
	end)
	repJanitor:add(player.AncestryChanged:Connect(function()
		if player.Parent == nil and repJanitor.destroy then
			repJanitor:destroy()
		end
	end))

	-- Here we generate a dictionary of valid pathways that can be listened for
	local validPathways = {}
	if pathwaysToLimitTo then
		for _, pathway in pathwaysToLimitTo do
			local pathwayKey = State.getPathwayKey(pathway)
			if not validPathways[pathwayKey] then
				validPathways[pathwayKey] = true
			end
		end
	end
	
	-- Upon requesting and verifying, replication to client can now begin
	local function replicationHandler(player, ...: unknown): (boolean, string | {any})
		local pathway = {...}
		for _, value in pathway do
			if typeof(value) ~= "string" then
				return false, "Pathways must be strings"
			end
		end
		local pathwayKey = State.getPathwayKey(pathway)
		local isWithinMaxSize = require(modules.VerifyUtil.isWithinMaxSize)
		local isValidSize, actualSize = isWithinMaxSize(pathwayKey, 200)
		if pathwaysToLimitTo == nil then
			-- We perform additional checks here as a malicious client could flood
			-- the server with unlimited pathways to listen for
			if isValidSize == false then
				return false, "Incoming pathway exceeded maximum bytes"
			end
			if activeListenersSize + actualSize > 10000 then
				return false, "Total active listeners exceeded maximum size"
			end
		end
		if activeListeners[pathwayKey] then
			return false, `Already listening for pathway '{pathwayKey}'`
		end
		if pathwaysToLimitTo then
			local isValid = false
			local partialPathway = {} :: {string}
			for i, key in pathway do
				table.insert(partialPathway, key)
				local parialPathwayKey = State.getPathwayKey(partialPathway)
				if validPathways[parialPathwayKey] then
					isValid = true
					break
				end
			end
			if not isValid then
				return false, `Not allowed to listen for pathway '{pathwayKey}'`
			end
		end
		activeListenersSize += actualSize
		activeListeners[pathwayKey] = true
		local currentValue = self:get(table.unpack(pathway))
		return true, currentValue
	end
	replicationHandlers[replicationKey] = replicationHandler
	
	-- Replicate all valid changes to the client
	local stateEvent = stateReplication :: any
	repJanitor:add(self:changed(function(pathwayKey: string, value: any)
		if activeListeners[pathwayKey] then
			local pathway = State.getPathway(pathwayKey)
			stateEvent:fireClient(player, replicationKey, pathway, value)
		end
	end))

	return self:_createConnection(function()
		if repJanitor.destroy then
			repJanitor:destroy()
		end
	end)
end

function State.bind(self: Class, replicationName: string)
	if RunService:IsClient() == false then
		error("State.bind can only be called on the client")
	end
	if self._bindingReplicationKey ~= nil then
		error("Client state tables can only bind to one server state at a time")
	end
	local userId = Players.LocalPlayer.UserId
	local replicationKey = `{userId}_{replicationName}`
	self._bindingReplicationKey = replicationKey :: any
	local janitor = self.janitor
	if stateReplication == nil then
		stateReplication = Remote.get("StateReplication")
	end
	stateReplication = stateReplication :: Remote.Class
	if stateReplication == nil then
		error("StateReplication remote does not exist")
	end
	local selfClass = self :: Class
	janitor:add(stateReplication:onClientEvent(function(replicationKey: string, pathway, value)
		if replicationKey ~= self._bindingReplicationKey then
			return
		end
		table.insert(pathway, value)
		selfClass:set(table.unpack(pathway))
	end))
	return
end

function State.fetch(self: Class, ...: string | (...any) -> (...any))
	-- Same as fetchAsync, but this has a one time optional callback
	-- This can be useful for scenarios where you want to load data from the server
	-- and to then listen for it via :changed, because all you have to then do is
	-- call :fetch("Cash"), :fetch("Exp"), etc. It's also useful of course for
	-- scenarious where you only need to observe the value once
	local totalArgs = select("#", ...)
	local finalArg = select(totalArgs, ...)
	local pathway = {...}
	local callback = nil
	if typeof(finalArg) == "function" then
		callback = finalArg
		table.remove(pathway, totalArgs)
	end
	task.spawn(function()
		local success, value = self:fetchAsync(table.unpack(pathway :: {string}))
		if success and callback then
			callback(value)
		end
	end)
end

function State.fetchAsync(self: Class, ...: string): (boolean, string | {any})
	-- This is useful for when you want to fetch the data from the server and to then
	-- have its value passed in the given callback.
	-- This can only be used on the client
	local pathway = {...} :: {string}
	if RunService:IsClient() == false then
		error("State.bind can only be called on the client")
	end
	if self._bindingReplicationKey == nil then
		error("State.fetchAsync can only be called after State.bind")
	end
	local pathwayKey = State.getPathwayKey(pathway)
	local requestingBindings = self._requestingBindings :: {[string]: any}
	local successfulBindings = self._successfulBindings :: {[string]: any}
	while requestingBindings[pathwayKey] do
		task.wait()
	end
	if successfulBindings[pathwayKey] then
		-- Already fetched and syncing from server, simply return what we have
		-- already on client
		local value = self:get(table.unpack(pathway))
		return true, value
	end
	if stateReplicationRequest == nil then
		stateReplicationRequest = Remote.get("StateReplicationRequest")
	end
	requestingBindings[pathwayKey] = true
	if stateReplicationRequest == nil then
		error("StateReplicationRequest remote does not exist")
	end
	stateReplicationRequest = stateReplicationRequest :: Remote.Class
	local success, approved, value = stateReplicationRequest:invokeServerAsync(self._bindingReplicationKey, ...)
	requestingBindings[pathwayKey] = nil
	if not success then
		return false, approved
	end
	if not approved then
		return false, value
	end
	successfulBindings[pathwayKey] = true
	table.insert(pathway, value)
	self:set(table.unpack(pathway))
	return true, value
end

function State.destroy(self: Class)
	if self.isActive == false then
		return
	end
	self.isActive = false
	self.janitor:destroy()
end


return State