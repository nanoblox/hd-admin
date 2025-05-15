--!strict
--[[

This is a User object that is used to manage user data and state.
It includes behaviour for loading user data, getting policy information, and managing
the automatic saving and replication of user data.
This is especially useful for Commands which accept User objects (instead of the Player instance)
as it enables the ability to create 'fake users' with for example elevated permissions,
without having to build any additional logic around to account for these.

Overview:
	- There are three main State objects: user.perm, user.temp, and User.everyone
	- Data within user.perm is persistent and saved to the datastore
	- Data is saved on a need-to-save basis, and when the player leaves, with
	  cooldowns and delays to handle limits appropriately. Data is serialized and (if specified) compressed.
	- Data within user.temp is temporary and not saved to the datastore
	- *Everyone* within User.everyone is retrievable by *everyone* (i.e. all clients)
	- 'Public' data within user.perm and user.temp is retrievable by the client of the user
	- 'Private' data within user.perm and user.temp is not retrievable
	- Public and Private data can be customized within the modules under DataStores
	- Values are set with :set, for example, perm:set("Cash", 100)
	- Values are viewed with :get, for example, local canJumpBool = perm:get("Roles", "Admin", "CanJump)
	- Values can also be listened with :observe and :listen - see State for more details
	- User objects are automatically destroyed if its given key is a player and when
	  that player leaves the game
	- To prevent rapid leave/join abuse, the user will block the loading of user data if their
	  total saves within the last minute exceed 5. This will rarely if never be exceeded
	  (maybe unless teleporting a lot and rapidly between servers), and is essential in
	  preventing malicious users from destroying the game's global limits
	  
]]


-- CONFIG
local SAVE_IN_STUDIO = false
local AUTO_SAVE_COOLDOWN = 60
local SESSION_LOCK_RELEASE_RETRIES = 4
local MAX_SAVES_PER_MINUTE = 5


-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local RunService = game:GetService("RunService")
local users: {[string]: Class} = {}
local Janitor = require(modules.Objects.Janitor)
local State = require(modules.Objects.State)
local Signal = require(modules.Objects.Signal)
local User = {}
User.__index = User



-- PUBLIC
User.userAdded = Signal.new()
User.userLoaded = Signal.new()
User.userRemoved = Signal.new()
User.everyone = State.new(false)


-- FUNCTIONS
function User.getRealKey(playerOrKey: UserKey): (string, boolean)
	-- If is a player object, then their actual key becomes tostring(player.UserId)
	local isPlayer = if typeof(playerOrKey) == "Instance" and playerOrKey:IsA("Player") then true else false
	if isPlayer then
		playerOrKey = playerOrKey :: Player
		return tostring(playerOrKey.UserId), isPlayer
	elseif typeof(playerOrKey) == "string" then
		return playerOrKey, isPlayer
	elseif typeof(playerOrKey) == "number" then
		return tostring(playerOrKey), isPlayer
	end
	error(`playerOrKey '{playerOrKey}' must be a Player or string`)
end

function User.getUser(playerOrKey: UserKey, canBeUnloaded: boolean?): Class?
	-- If is a player object, then their actual key becomes tostring(player.UserId)
	local realKey = User.getRealKey(playerOrKey)
	local user = users[realKey]
	if not user then
		return nil
	end
	if not canBeUnloaded and user.isLoaded == false then
		return nil -- User must be loaded!
	end
	return user
end

function User.getUserAsync(playerOrKey: UserKey): (boolean, Class)
	local realKey, isPlayer = User.getRealKey(playerOrKey)
	local checks = 0
	while true do
		if isPlayer and typeof(playerOrKey) == "Instance" and playerOrKey.Parent == nil then
			return false, `Player '{playerOrKey.Name}' ({playerOrKey.UserId}) left the server` :: any
		end
		local user = users[realKey]
		if not user and checks > 0 then
			return false, `User '{realKey}' does not exist`  :: any
		end
		if user and user.isLoaded == true then
			return true, user
		end
		checks += 1
		task.wait()
	end
end

function User.getUsers(canBeUnloaded: boolean?): {Class}
	local usersArray = {}
	for _, user in pairs(users) do
		user = user :: Class
		if not canBeUnloaded and user.isLoaded == false then
			continue
		end
		table.insert(usersArray, user)
	end
	return usersArray
end

function User._getSavesThisMinute(dataTable, andIncrement)
	local nextRefreshTime = dataTable._nextRefreshTime
	local timeNow = os.time()
	if nextRefreshTime == nil or timeNow >= nextRefreshTime then
		nextRefreshTime = timeNow + 60
		dataTable._nextRefreshTime = nextRefreshTime
		dataTable._savesThisMinute = nil :: any
	end
	local savesThisMinute: number = dataTable._savesThisMinute or 0
	if andIncrement then
		savesThisMinute += 1
		dataTable._savesThisMinute = savesThisMinute
	end
	return savesThisMinute
end

function User.incrementSavesThisMinute(dataTable)
	return User._getSavesThisMinute(dataTable, true)
end


-- CONSTRUCTOR
function User.new(playerOrKey: UserKey, dataStoreName: string?)

	-- Define properties
	local realKey, isPlayer = User.getRealKey(playerOrKey)
	local janitor = Janitor.new()
	local player = if isPlayer then playerOrKey :: Player else nil
	local self = {
		janitor = janitor,
		perm = State.new(true), -- We don't destroy perm until after a successful save and release
		temp = janitor:add(State.new(false)),
		beforeLoading = janitor:add(Signal.new()),
		beforeSaving = janitor:add(Signal.new()),
		realKey = realKey :: string,
		player = player,
		policyInfo = {},
		policyInfoLoaded = false :: boolean,
		isPlayer = isPlayer :: boolean,
		isLoading = false :: boolean,
		isLoaded = false :: any,
		isActive = true :: boolean,
	}
	setmetatable(self, User)

	-- If an existing user is present (for example, in rare cases where a player
	-- rejoins the server before the old user is removed), then call destroy on that
	-- old user and replace it with the new one
	local oldUser = users[realKey]
	if oldUser then
		oldUser:destroy()
	end
	users[realKey] = self
	User.userAdded:fire(self)
	janitor:add(function()
		if users[realKey] == self then
			users[realKey] = nil
		end
		User.userRemoved:fire(self)
	end)

	-- If a player is present, then destroy this user when the player leaves
	-- We also automatically load policyInfo so that it can be retrieved as soon
	-- as possible by both server and client (assuming Public temp contains 'PolicyInfo')
	if player then
		task.spawn(function()
			while self.isActive and not self.policyInfo do
				self:getPolicyInfoAsync()
				task.wait()
			end
		end)
		janitor:add(player.AncestryChanged:Connect(function()
			if player.Parent == nil then
				self:destroy()
			end
		end))
	end

	-- If a dataTemplateGenerator is provided, then begin the loading and handling of data
	if dataStoreName then
		self:_loadAndAutoSaveData(dataStoreName)
	end

	return self
end


-- CLASS
export type Class = typeof(User.new(...))
type UserKey = (Player | string | number)?


-- METHODS
function User._loadAndAutoSaveData(self: Class, dataStoreName: string)
	if typeof(dataStoreName) ~= "string" then
		error("dataStoreName must be a string")
	end 
	local dataStores = modules.DataStores
	local store = dataStores:FindFirstChild(dataStoreName)
	if not store then
		error(`DataStore '{dataStoreName}' does not exist`)
	end
	if self.isLoading or self.isLoaded or self.isActive == false then
		return
	end
	
	-- This sets up the replication of state based upon the given public and private data
	local DataStores = require(dataStores) :: any
	local Store = require(store) :: any
	local template = Store.generateTemplate(self)
	local janitor = self.janitor
	local player = self.player
	local perm = self.perm
	local temp = self.temp
	local startData = {
		perm = {},
		temp = {},
	}
	if player and typeof(player) == "Instance" and player:IsA("Player") then
		local function getPathwaysToLimitTo(dataType)
			local limiters: {{string}} = {}
			for _, detail in template do
				detail = detail :: {any}
				local items = detail[3]
				local startTable = startData[dataType]
				if detail[1] == dataType then
					if detail[2] == "public" then
						for key, _ in items do
							local pathway = {key}
							table.insert(limiters, pathway)
						end
					end
					for key, value in items do
						startTable[key] = value
					end
				end
			end
			return limiters
		end
		local permLimiters = getPathwaysToLimitTo("perm")
		local tempLimiters = getPathwaysToLimitTo("temp")
		janitor:add(perm:replicate(player, `UserPerm`, permLimiters))
		janitor:add(temp:replicate(player, `UserTemp`, tempLimiters))
		janitor:add(User.everyone:replicate(player, `UserEveryone`))
	end
	
	-- We set temp data so it can be accessed via .getUser(key, true) even if perm data hasn't loaded
	temp:setAll(startData.temp)

	-- We attempt to load data indefinitely until success or until the player leaves
	local loadedData: any = nil
	local realKey = self.realKey
	local Serializer = require(modules.Utility.Serializer)
	local waitTimeRetry = 2
	local retries = 0
	local firstSessionLockRejectTime: number? = nil
	while true do
		if self.isActive == false then
			return
		end
		
		-- Here we load the data via updateAsync to firstly ensure it's not been sessionLocked
		-- by another server (for example, if the player teleported rapidly between servers),
		-- and then if not sessionLocked, we immidiately modify the data so that is recorded
		-- with a sessionLock, so that no other server can accidentally modify this data until
		-- it has been successfully released. Thank you loleris for this idea
		local dataHasLoaded = true
		local dataFailedReason = nil
		local customWaitTime: number? = nil
		local success, warning = DataStores.updateAsync(dataStoreName, realKey, function(incomingData: any)
			-- If the data is a string, then it is compressed and needs to be decompressed
			if typeof(incomingData) == "string" then
				incomingData = Serializer.decompress(incomingData)
			end
			if typeof(incomingData) ~= "table" then
				incomingData = {}
			end
			local timeNow = os.time()
			local lastSavedTime = incomingData._lastSavedTime or timeNow
			local timeSinceLastSaved = timeNow - lastSavedTime
			local incomingSessionLock = incomingData._sessionLock
			local exceededTeleportCooldown = timeSinceLastSaved > 150
			if incomingSessionLock ~= nil and not exceededTeleportCooldown then
				-- There's a rare possibility that the session lock is not released when the player leaves
				-- if roblox's datastore services failed continuously *and* if the server shutdown before
				-- the session lock could be saved.
				if firstSessionLockRejectTime == nil then
					firstSessionLockRejectTime = timeNow
				end
				local timeSinceFirstReject = timeNow - firstSessionLockRejectTime :: number
				local keepRetrying = retries < SESSION_LOCK_RELEASE_RETRIES
				if keepRetrying or incomingSessionLock == "Studio" or RunService:IsStudio() then
					dataFailedReason = "Unable to load data as it is currently session locked"
					dataHasLoaded = false
					return nil
				end
				warn(`HD admin ignored session lock for user '{realKey}' as it was locked for over {timeSinceFirstReject} seconds - this may result in a loss of progress. This should only happen in rare occassions where Roblox's datastores fail for an extended period. If this regularly occurs, contact ForeverHD.`)
			end
			loadedData = incomingData
			if SAVE_IN_STUDIO == false and RunService:IsStudio() then
				-- It's important we don't modify the data in studio in anyway
				-- if SAVE_IN_STUDIO is false, as this could cause issues with the
				-- sessionLock not being applied/removed correctly
				return nil
			end
			local savesThisMinute = User._getSavesThisMinute(incomingData)
			if savesThisMinute > MAX_SAVES_PER_MINUTE then
				-- Block loading if the user has exceeded the maximum saves per minute
				local nextRefreshTime = incomingData._nextRefreshTime + 1 or timeNow + 3
				dataFailedReason = "Unable to load data as user has exceeded the maximum saves per minute"
				dataHasLoaded = false
				customWaitTime = nextRefreshTime - timeNow
				return nil
			end
			local jobId = if RunService:IsStudio() then "Studio" else game.JobId
			if player then
				-- We only apply session locks for users with associated players, as session hopping
				-- is only a danger for real players (if data is lost for non-players then that's because
				-- of incorrect programming)
				incomingData._sessionLock = jobId
			end
			User.incrementSavesThisMinute(incomingData)
			return incomingData
		end)
		if dataFailedReason then
			warning = dataFailedReason
		end
		if success and dataHasLoaded then
			break
		end
		if customWaitTime then
			task.wait(customWaitTime)
		else
			warn(`HD Admin failed to load data for '{realKey}' from '{dataStoreName}': {warning}`)
			waitTimeRetry *= 2
			retries += 1
			task.wait(waitTimeRetry)
		end
	end

	-- Cancel if user destroyed
	if self.isActive == false then
		return
	end

	-- Provide another warning of success if initially failed
	if retries > 0 then
		warn(`HD Admin finally loaded data for '{realKey}' from '{dataStoreName} after {retries} retries`)
	end

	-- Deserialize data if was originally serialized
	if typeof(loadedData) == "table" and loadedData._isSerialized == true then
		loadedData._isSerialized = nil :: any
		loadedData = Serializer.deserialize(loadedData)
	end
	
	local gdprUserIds = {}
	if player then
		table.insert(gdprUserIds, player.UserId)
	end

	-- This merges the loaded data ontop of the default template of keys and values
	-- This performs a recursive merge, so that nested tables are also merged
	-- if that table is a dictionary (and not an array)
	local permStartData = startData.perm
	if typeof(loadedData) == "table" then
		local function mergeDataRecursive(dataToMerge, originalData)
			for key, value in dataToMerge do
				if typeof(value) == "table" and #value == 0 then
					local originalValue = originalData[key]
					if originalValue == nil then
						originalValue = {}
						originalData[key] = originalValue
					end
					mergeDataRecursive(value :: any, originalValue :: any) -- {any}
				else
					originalData[key] = value
				end
			end
			return originalData
		end
		mergeDataRecursive(loadedData :: {any}, permStartData)
	end
	perm:setAll(permStartData :: any)
	
	-- This handles the saving of data and the releasing of the session lock
	local isReleasingProfile = false
	local hasReleasedProfile = false
	local serverIsShuttingDown = false
	local function saveAsync()
		if isReleasingProfile then
			return false, "Already releasing profile"
		end
		if SAVE_IN_STUDIO == false and RunService:IsStudio() then
			hasReleasedProfile = true
			return false, "In studio"
		end
		local isActive = self.isActive :: boolean
		if isActive == false or serverIsShuttingDown then
			isReleasingProfile = true
		end
		local beforeSaving = self.beforeSaving :: Signal.Class
		beforeSaving:fire(isReleasingProfile) -- This is fired before saving, so that any data can be modified before saving
		local dataToSave = perm:getAll(true)
		User.incrementSavesThisMinute(dataToSave)
		dataToSave._isSerialized = true
		dataToSave._lastSavedTime = os.time()
		if isReleasingProfile then
			dataToSave._sessionLock = nil
		end
		if Store.compressData then
			dataToSave = Serializer.compress(dataToSave)
		end
		local success, warning
		while success ~= true do
			success, warning = DataStores.setAsync(dataStoreName, realKey, dataToSave, gdprUserIds)
			if not success then
				warn(`HD Admin failed to save data for '{realKey}' to DataStore '{dataStoreName}': {warning}`)
			end
			if not isReleasingProfile then
				-- If releasing (i.e. player leaving), then we indfintely retry until success
				-- If not releasing, then we only attempt once before returning warning
				break
			end
		end
		if isReleasingProfile and success then
			hasReleasedProfile = true
			perm:destroy() -- Now we can destroy self.perm
		end
		return success, warning
	end

	-- Call the beforeLoading signal to allow for any data to be modified before loading
	local beforeLoading = self.beforeLoading :: Signal.Class
	beforeLoading:fire()
	
	-- Save data and release session when player leaves
	self.janitor:add(function()
		task.defer(saveAsync)
	end)

	-- Save data and release session when server is shutting down
	-- Binding to close in studio can negatively impact the experience of a developer
	-- as it forces play test end to hang until bind to close is complete
	game:BindToClose(function()
		serverIsShuttingDown = true
		task.defer(saveAsync)
		while hasReleasedProfile == false do
			task.wait(1)
		end
	end)
	
	-- This acts as an 'auto save', with the added bonus of only saving data *when it needs*
	-- to be saved. It applies a cooldown of AUTO_SAVE_COOLDOWN seconds between saves
	local Queue = require(modules.Objects.Queue)
	local queue = Queue.new()
	perm:changed(function()
		queue:add(function()
			local INITIAL_DELAY = 1
			task.wait(INITIAL_DELAY) -- Wait a second to include addiitonal values if a lot of changes are made at once
			queue:clear()
			saveAsync()
			task.wait(AUTO_SAVE_COOLDOWN-INITIAL_DELAY)
		end)
	end)

	-- Now fire that we have loaded!
	self.isLoaded = true :: any
	if self.isActive then
		User.userLoaded:fire(self)
	end

end

function User.getPolicyInfoAsync(self: Class): (boolean, string | any)
	-- Retrieves the policy information for the player
	-- Also syncs it into temp.PolicyInfo so that it can be accessed by the client
	local policyInfo = self.policyInfo
	if not self.isPlayer then
		return false, "User is not a player"
	end
	local player = self.player :: Player
	if self.policyInfoLoaded then
		return true, policyInfo
	end
	local PolicyService = game:GetService("PolicyService")
	local success, warningOrPolicy = false, ""
	for i = 1, 4 do
		success, warningOrPolicy = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(player)
		end)
		if success then
			local temp = self.temp :: State.Class
			temp:set("PolicyInfo", warningOrPolicy)
			return true, warningOrPolicy
		end
		task.wait(3)
	end
	return false, warningOrPolicy
end

function User.destroy(self: Class)
	if self.isActive == false then
		return
	end
	self.isActive = false :: any
	self.janitor:destroy()
end


return User