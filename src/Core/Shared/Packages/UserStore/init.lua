-- LOCAL
local replicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(script.Maid)
local User = require(script.User)
local UserStore = {}
UserStore.__index = UserStore

local function getKey(keyOrPlayer)
	local isPlayer = (type(keyOrPlayer) == "userdata" and keyOrPlayer.UserId)
	return (isPlayer and tostring(keyOrPlayer.UserId)) or keyOrPlayer, isPlayer
end



-- CONSTRUCTOR
function UserStore.new(dataStoreName)
	local self = {}
	setmetatable(self, UserStore)
	
	self.dataStoreName = dataStoreName
	self.users = {}
	
	return self
end



-- METHODS
function UserStore:createUser(originalKey)
	local key, isPlayer = getKey(originalKey)
	assert(not self.users[key], ("user '%s' already exists!"):format(key))
	local user = User.new(self.dataStoreName, key)
	self.users[key] = user
	user.player = isPlayer and originalKey
	user.name = isPlayer and originalKey.Name
	user.userId = isPlayer and originalKey.UserId
	coroutine.wrap(function()
		user:loadAsync()
	end)()
	return user
end

function UserStore:getUser(originalKey)
	local key = getKey(originalKey)
	return self.users[key]
end

-- *Player key specific
function UserStore:getUserByUserId(userId)
	for key, user in pairs(self.users) do
		if tonumber(key) == tonumber(userId) then
			return self:getUser(user.player)
		end
	end
end

-- *Player key specific
function UserStore:getUserByName(name)
	for player, user in pairs(self.users) do
		if player.Name == name then
			return self:getUser(player)
		end
	end
end

function UserStore:getUsers()
	local usersArray = {}
	for key, user in pairs(self.users) do
		table.insert(usersArray, user)
	end
	return usersArray
end

function UserStore:getLoadedUser(key)
	local user = self:getUser(key)
	if user and user.isLoaded then
		return user
	end
end

-- *Player key specific
function UserStore:getLoadedUserByUserId(userId)
	for key, user in pairs(self.users) do
		if tonumber(key) == tonumber(userId) then
			return self:getLoadedUser(user.player)
		end
	end
end

-- *Player key specific
function UserStore:getLoadedUserByName(name)
	for player, user in pairs(self.users) do
		if player.Name == name then
			return self:getLoadedUser(player)
		end
	end
end

function UserStore:getLoadedUsers()
	local usersArray = {}
	for key, user in pairs(self.users) do
		if user.isLoaded then
			table.insert(usersArray, user)
		end
	end
	return usersArray
end

function UserStore:grabData(originalKey)
	local key = getKey(originalKey)
	local user = User.new(self.dataStoreName, key)
	local data = user:loadAsync()
	user:destroy()
	return data
end

-- *Player key specific
function UserStore:createLeaderstat(player, statToBind)
	local maidName = "_maid"..player.Name..tostring(statToBind)
	if self[maidName] then
		return
	end
	local maid = Maid.new()
	self[maidName] = maid
	local dataTypes = {"perm", "temp"}
	local user = self:getUser(player)
	if not user then
		return false
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end
	local statInstance = maid:give(Instance.new("StringValue"))
	statInstance.Name = statToBind
	statInstance.Value = "..."
	coroutine.wrap(function()
		user:waitUntilLoaded()
		for _, dataName in pairs(dataTypes) do
			statInstance.Value = user[dataName]:get(statToBind) or statInstance.Value
		end
	end)()
	statInstance.Parent = leaderstats
	for _, dataName in pairs(dataTypes) do
		maid:give(user[dataName].changed:Connect(function(stat, value, oldValue)
			if statInstance and statInstance.Value and stat == statToBind then
				statInstance.Value = tostring(value)
			end
		end))
	end
	return statInstance
end

-- *Player key specific
function UserStore:removeLeaderstat(player, statToUnbind)
	local maidName = "_maid"..player.Name..tostring(statToUnbind)
	local maid = self[maidName]
	if maid then
		maid:clean()
		for k, _ in pairs(self) do
			self[k] = nil
		end
		self[maidName] = nil
	end
	return true
end

function UserStore:removeUser(originalKey)
	local key = getKey(originalKey)
	local user = self:getUser(key)
	if user then
		user:saveAsync()
		user:destroy()
	end
	self.users[key] = nil
end



return UserStore