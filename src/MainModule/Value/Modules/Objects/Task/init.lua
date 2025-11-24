--[[

	"Tasks" are the objects created every time a command is run, and are destroyed when the
	command finishes running, or when the command is ended (e.g. by the user, or by a timeout).

	They come with their own 'defer', 'delay, 'wait', etc methods that must be used instead of
	the standard task methods, as they ensure the task is tracked and cleaned up properly.
	They additionally make it possible to 'pause' and 'resume' command tasks.

]]


-- CONFIG
--!strict
local ERROR_START = "HD Admin Command Error: "


-- LOCAL
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Janitor = require(modules.Objects.Janitor)
local Args = require(modules.Parser.Args)
local Signal = require(modules.Objects.Signal)
local RunService = game:GetService("RunService")
local deepCopyTable = require(modules.TableUtil.deepCopyTable)
local generateUID = require(modules.DataUtil.generateUID)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getTargets = require(modules.PlayerUtil.getTargets)
local registerSound = require(modules.AssetUtil.registerSound)
local isServer = RunService:IsServer()
local isClient = not isServer
local Remote = require(modules.Objects.Remote)
local endClientTask: Remote.Class? = nil
local allBuffs = {} :: {Buff}
local ignoreBuffTags = {} :: {[string]: true}
local tasks = {}
local TaskClient = require(script.TaskClient)
local TaskServer = require(script.TaskServer)
local Task = {}
Task.__index = Task


-- FUNCTIONS
function Task.getTask(UID: string?): Class?
	return tasks[tostring(UID)]
end

function Task.getTasks(commandName: string?, targetUserId: number?): {Class}
	local tasksToReturn = {} :: {any}
	local commandNameLower = if commandName then commandName:lower() else nil
	local stringTargetUserId = tostring(targetUserId)
	for _, task in tasks do
		local ourNameLower = task.commandNameLower
		local ourUserId = tostring(task.targetUserId)
		if (not commandNameLower or ourNameLower == commandNameLower) and (not targetUserId or ourUserId == stringTargetUserId) then
			table.insert(tasksToReturn, task)
		end
	end
	tasksToReturn = tasksToReturn :: {Class}
	return tasksToReturn
end


-- CONSTRUCTOR
function Task.new(properties: Properties)
	return Task.construct(properties) :: Class
end

function Task.construct(properties: Properties)

	-- Define properties
	local janitor = Janitor.new()
	local commandName = properties.commandName
	local callerUserId = properties.callerUserId
	local targetUserId = properties.targetUserId
	local UID = properties.UID or generateUID()
	local services = modules.Parent.Services
	local dictOfGroupsLower = {}
	local cooldown = 0
	if isServer then
		local Commands = require(services.Commands) :: any
		local command = Commands.getCommand(commandName) :: Command?
		local groups = command and command.groups
		if typeof(groups) == "table" then
			for _, groupName in groups do
				local nameLower = tostring(groupName):lower()
				dictOfGroupsLower[nameLower] = true
			end
		end
		local thisCooldown = command and command.cooldown
		if thisCooldown and typeof(thisCooldown) == "number" and thisCooldown > 0 then
			cooldown = thisCooldown
		end
	end
	local self = {
		
		-- Public
		janitor = janitor,
		UID = UID,
		isActive = true :: any,
		bypassLimits = false :: any,  --!!! roles: CHECK IF USER ROLES
		caller = if callerUserId then Players:GetPlayerByUserId(callerUserId) else nil,
		target = if targetUserId then Players:GetPlayerByUserId(targetUserId) else nil,
		client = TaskClient.new(UID),
		server = TaskServer.new(UID),

		-- Private
		isPaused = false,
		pauseTime = 0,
		holdsToResume = {} :: {any},
		callerUserId = callerUserId,
		targetUserId = targetUserId,
		commandName = commandName,
		commandNameLower = tostring(commandName):lower(),
		args = properties.args,
		modifiers = properties.modifiers,
		qualifiers = properties.qualifiers,
		isRestricted = properties.isRestricted,
		isRunning = false,
		originalArgReturnValues = {} :: {[string]: any},
		originalArgReturnValuesFromIndex = {} :: {[number]: any},
		activeHolds = 0,
		resumed = nil :: Signal.Signal<any>?,
		clientArgs = properties.clientArgs,
		activeClientTasks = {} :: {[string]: true},
		cooldownEndTime = nil :: number?,
		hasCompletedCooldown = false :: boolean,
		cooldown = cooldown,
		dictOfGroupsLower = dictOfGroupsLower,
	}
	setmetatable(self, Task)
	tasks[UID] = self :: any
	
	task.defer(function()
		self:run()
		self:checkToDestroy()
	end)

	-- TASK LIBRARY WRAPPERS
	function self.spawn(callback: () -> ())
		self:registerHold()
		task.spawn(function()
			self:unregisterHold(callback)
		end)
	end

	function self.defer(callback: () -> ())
		self:registerHold()
		task.defer(function()
			self:unregisterHold(callback)
		end)
	end

	function self.delay(delayTime:number, callback: () -> ()?)
		self:registerHold()
		if callback == nil then
			callback = function() end
		end
		task.delay(delayTime, function()
			self:unregisterHold(callback)
		end)
	end

	function self.wait(yieldTime:number?)
		self:registerHold()
		task.wait(yieldTime)
		self:unregisterHold()
	end

	function self.iterate(iterations: number, callback: (i: number) -> ())
		for i = 1, iterations do
			if not self.isActive then
				return
			end
			self:registerHold()
			self:unregisterHold(callback :: any, nil, i)
		end
	end

	function self.loop(callback: (stop: () -> (), i: number) -> ())
		local iterations = 0
		local isLoopActive = true
		local function stop()
			isLoopActive = false
		end
		while self.isActive and isLoopActive do
			iterations += 1
			self:registerHold()
			self:unregisterHold(callback :: any, nil, stop, iterations)
		end
	end

	return self
end


-- PRIVATE METHODS
function Task.run(self: Task)
	
	-- Only run if command is present
	local run: any? = nil
	local command: Command? = nil
	local commandName = self.commandName
	local args = self.args
	if isServer then
		local services = modules.Parent.Services
		local Commands = require(services.Commands) :: any
		command = Commands.getCommand(commandName) :: Command?
		run = if command then command.run else nil
	elseif isClient then
		local controllers = modules.Parent.Controllers
		local ClientCommands = require(controllers.ClientCommands) :: any
		command = ClientCommands.getCommand(commandName) :: Command?
		run = if command then command.run else nil
	end
	if not run then
		return false
	end
	if self.isRunning or not self.isActive then
		return false
	end
	self.isRunning = true

	-- This retrieves the details of the first arg
	local firstCommandArg = nil
	local firstArgItem = nil
	local commandArgs = nil
	local qualifiers = self.qualifiers
	local callerUserId = self.callerUserId
	local targetUserId = self.targetUserId
	if args then
		commandArgs = if command then command.args else {}
		firstCommandArg = commandArgs[1]
		firstArgItem = Args.get(firstCommandArg :: any)
	end

	-- For when a command finishes running
	local function runningDone()
		self.isRunning = false
		self:checkToDestroy()
	end

	-- This is what parses the args and runs the actual command function
	local function runCommand(parseArgs, ...)
		local additional = table.pack(...)
		
		-- Convert arg strings into arg values
		-- Only execute the command once all args have been converted
		-- Some arg parsers, such as text, may be aschronous due to filter requests
		if isServer and parseArgs and args and commandArgs then
			local currentArgs = additional[1]
			local parsedArgs = if type(currentArgs) == "table" then currentArgs else nil
			if not parsedArgs then
				parsedArgs = {}
				additional[1] = parsedArgs
			end
			local firstAlreadyParsedArg = parsedArgs[1]
			local i = #parsedArgs + 1
			for _, _ in commandArgs do
				local iNow = i
				local argName = commandArgs[iNow]
				local argItem = Args.get(argName :: any)
				i += 1
				if not argItem then
					break
				end
				local argStringIndex = (firstAlreadyParsedArg and iNow - 1) or iNow
				local argString = args[argStringIndex :: any] or ""
				if argItem.playerArg then
					argString = {
						[argString] = {}
					}
				end
				local returnValue = argItem:parse(argString, callerUserId, targetUserId)
				local argNameLower = tostring(argName):lower()
				self.originalArgReturnValues[argNameLower] = returnValue
				self.originalArgReturnValuesFromIndex[iNow] = returnValue
				if returnValue == nil then
					local defaultValue = argItem.defaultValue
					if typeof(defaultValue) == "table" then
						defaultValue = deepCopyTable(argItem.defaultValue)
					end
					returnValue = defaultValue
				end
				parsedArgs[iNow] = returnValue
			end
		end
		
		-- Once all args have been parsed, run the command
		-- We wrap with xpcall as it enables the job to be cleaned up even if the
		-- command throws an error
		xpcall(run, function(errorMessage)
			warn(ERROR_START..tostring(errorMessage))
		end, self, unpack(additional))
		runningDone()

		return true
	end

	-- If client job, execute with job.clientArgs
	if isClient then
		return runCommand(false, unpack(self.clientArgs))
	end

	-- If the job is player-specific (such as in ;kill foreverhd, ;kill all) find the associated player and execute the command on them
	local propsTarget = self.target
	if propsTarget then
		return runCommand(true, {propsTarget})
	end
	
	-- If the job has no associated player or qualifiers (such as in ;music <musicId>) then simply execute right away
	if firstArgItem and not firstArgItem.playerArg then
		return runCommand(true, {})
	end

	-- If the job has no associated player *but* does contain qualifiers...
	-- ...that require executing for each player (such as in ;globalKill all)
	local targetPlayers = if firstArgItem then firstArgItem:parse(qualifiers, callerUserId) else nil
	if firstArgItem and firstArgItem.runForEachPlayer then -- If the firstArg has runForEachPlayer, convert the job into subjobs for each player returned by the qualifiers
		for i, plr in targetPlayers do
			local subProperties: Properties = {
				targetUserId = plr.UserId,
				callerUserId = self.callerUserId,
				commandName = self.commandName,
				args = self.args,
				modifiers = self.modifiers,
				qualifiers = self.qualifiers,
				isRestricted = self.isRestricted,
			}
			Task.new(subProperties)
		end
		runningDone()
		return true
	end
	
	-- ...that require executing collectively (such as in ;bring all)
	return runCommand(true, {targetPlayers})
end

function Task.registerHold(self: Task)
	self.activeHolds += 1
end

function Task.unregisterHold(self: Task, callback: () -> ()?, remainingTime: number?, firstArg: any?, secondArg: any?)
	-- We hold the callback before calling it if the task is paused
	if self.isPaused and self.isActive then
		-- We save the callback for most task methods with a callback (spawn, defer, delay, etc)
		local durationRemaining = os.clock() - self.pauseTime
		if callback then
			table.insert(self.holdsToResume :: {any}, {callback, durationRemaining})
			return
		end
		-- For wait(), we instead have to pause the thread until the task is resumed
		local resumed = self.resumed
		if not resumed then
			resumed = self.janitor:add(Signal.new())
			self.resumed = resumed
		end
		self.resumed:Wait()
		remainingTime = durationRemaining :: number
	end
	if remainingTime and remainingTime > 0 and self.isActive then
		task.delay(remainingTime, function()
			self:unregisterHold(callback)
		end)
		return
	end
	if typeof(callback) == "function" and self.isActive then
		xpcall(callback :: any, function(errorMessage)
			warn(ERROR_START..tostring(errorMessage))
		end, firstArg, secondArg)
	end
	self.activeHolds -= 1
	if self.activeHolds <= 0 then
		-- If no more active holds, defer by a frame, and if still zero, consider killing
		-- the task. We don't outright destroy it as command persistence may keep it running
		task.defer(function()
			if self.activeHolds <= 0 then
				self:checkToDestroy()
			end
		end)
	end
end

function Task.pause(self: Task)
	self.pauseTime = os.clock()
	self.isPaused = true
end

function Task.resume(self: Task)
	self.isPaused = false
	for _, holdInfo in self.holdsToResume do
		local callback = holdInfo[1]
		local remainingTime = holdInfo[2]
		task.defer(function()
			self:unregisterHold(callback, remainingTime)
		end)
	end
	if self.resumed then
		self.resumed:Fire()
	end
end

function Task.checkToDestroy(self: Task)
	if self.isRunning then
		return
	end
	if self.activeHolds > 0 then
		return
	end
	self:destroy()
end

function Task.updateBuffs(self: Task, player: BuffPlayer?, group: BuffGroup?, ignoreOtherRequests: boolean?)
	if ignoreOtherRequests then
		local name = if typeof(player) == "Instance" then player.Name else player
		local buffTag = `{name}-{group}`
		if ignoreBuffTags[buffTag] then
			return
		end
		ignoreBuffTags[buffTag] = true
		task.defer(function()
			task.wait()
			ignoreBuffTags[buffTag] = nil
		end)
	end
	local sortedBuffs = {} :: {Buff}
	for _, buff in allBuffs do
		if player ~= nil and buff.player ~= player then
			continue
		end
		if group ~= nil and buff.group ~= group then --and buff.group ~= "All" then
			continue
		end
		table.insert(sortedBuffs, buff)
	end
	table.sort(sortedBuffs, function(buffA: Buff, buffB: Buff)
		local priorityBuffA = buffA.priority
		local priorityBuffB = buffB.priority
		if priorityBuffA ~= priorityBuffB then
			-- Sort buffs with higher priority first
			return priorityBuffA > priorityBuffB
		end
		-- Sort buffs added later first
		return buffA.timeAdded > buffB.timeAdded
	end)
	-- We call top buffs last so that they override lower priority buffs
	local totalToCall = #sortedBuffs
	for i = totalToCall, 1, -1 do
		local buff = sortedBuffs[i]
		local hasEnded = false
		local isTop = i == 1
		xpcall(buff.callback, function(errorMessage)
			warn(ERROR_START..tostring(errorMessage))
		end, hasEnded, isTop)
	end
end


-- PUBLIC METHODS
function Task.buff(self: Task, player: BuffPlayer, group: BuffGroup, priorityOrCallback: number | BuffCallback, callback: BuffCallback?)
	-- A buff is simply a collection of callbacks that are re-run in-order every time another buff
	-- of its group is applied or removed. This is useful for things like WalkSpeed, Health, etc
	-- where you want these effects to 'stack', instead of being reset the first time a command ends.
	-- This applies the buff accross all tasks of buffGroup
	-- Buffs are re-applied when:
	-- 1. A new buff of the same player+group is added
	-- 2. An existing buff of the same player+group is destroyed
	-- 3. When the player respawns (if player is a Player instance)

	-- The priority does not have to be specified in which case it defaults to 1
	-- This also enables shorthand instead of passing nil as the third argument
	local priority = priorityOrCallback
	if typeof(priorityOrCallback) == "function" then
		callback = priorityOrCallback
		priority = 1
	end

	-- Construct the buff
	-- It's important we provide a destroy method so that it can be manually removed
	-- If not manually, it will be removed when the task is destroyed
	local function destroyBuffCallback(buff: Buff)
		if buff.isActive == false then
			return
		end
		for i, buffToCheck in allBuffs do
			if buffToCheck == buff then
				table.remove(allBuffs, i)
				break
			end
		end
		local hasEnded = true
		local isTop = false
		buff.isActive = false
		xpcall(buff.callback, function(errorMessage)
			warn(ERROR_START..tostring(errorMessage))
		end, hasEnded, isTop)
		task.defer(function()
			-- We defer to give time for other identical buffs to remove themselves
			-- (such as when all tasks are cleaned up at the same time) so that only
			-- remaining buffs are processed and applied
			self:updateBuffs(player, group, true)
		end)
	end
	local buff: Buff = {
		player = player,
		group = group,
		priority = priority :: number,
		callback = callback :: BuffCallback,
		timeAdded = os.clock(),
		taskUID = self.UID,
		isActive = true,
		destroy = destroyBuffCallback,
		Destroy = destroyBuffCallback,
	}

	-- Player can be any player, or 'false' for server-wide buffs
	-- Typically the player argument will be the 'player' or 'caller'
	-- Its important we check that player ~= nil, as it can sometimes
	-- be nil (for example, the caller will be nil for global commands)
	-- If nil, then don't activate buff
	if player ~= "Server" and not (typeof(player) == "Instance" and player:IsA("Player")) then
		return buff
	end

	-- Re-apply the buff when the player respawns
	if typeof(player) == "Instance" and player:IsA("Player") then
		self.janitor:add(player.CharacterAdded:Connect(function(char)
			task.defer(function()
				if not self.isActive then
					return
				end
				self:updateBuffs(player, group, true)
			end)
		end))
	end

	-- Now register and update all relevant buffs
	self.janitor:add(buff)
	table.insert(allBuffs, buff)
	self:updateBuffs(player, group)

	return buff
end

function Task.redo(self: Task, player: Player?, callback: (hasEnded: boolean) -> ())
	-- "callback" is called 1. right away, 2. every time the player respawns (assuming
	-- the task is still active), and 3. when the task is destroyed. This is useful for
	-- behaviours that you want to re-apply past death - for example, when controlling
	-- another player, it's desirable to re-apply control when the target respawns.
	self:onEnded(function()
		callback(true)
	end)
	if typeof(player) == "Instance" and player:IsA("Player") then
		self.janitor:add(player.CharacterAdded:Connect(function(char)
			task.defer(function()
				if not self.isActive then
					return
				end
				callback(false)
			end)
		end))
	end
	self.spawn(function()
		callback(false)
	end)
end

function Task.keep(self: Task, persistence: Persistence?)
	-- Typically when a command finishes running the task is destroyed
	-- This method allows you to keep the task alive based on certain conditions
	-- For example, you may want a task which modifies walkspeed to only stay until
	-- the player respawns - this is achieved with persistence "UntilTargetRespawns".
	-- Persistence's can 'combine' - for example, if you call keep("UntilTargetLeaves")
	-- followed by keep("UntilCallerLeaves"), the task will be destroyed when either
	-- the player or caller leaves

	-- If persistence is not specified or "Indefinitely", we simply keep the task alive
	-- until it is manually ended
	self:registerHold()
	if typeof(persistence) ~= "string" or persistence == "Indefinitely" then
		return
	end

	-- This works out the player to track
	local trackingPlayer: Player? = nil
	local isCaller = persistence:match("Caller")
	if persistence:match("Target") then
		trackingPlayer = self.target
	elseif isCaller then
		trackingPlayer = self.caller
	end
	if not trackingPlayer then
		return
	end

	-- This determines the action to track
	local action = persistence:match("([A-Z][a-z]+)$")
	if not action then
		return
	end

	-- If the original source task contains a Caller persistence (e.g. end after caller leaving),
	-- then it's important we also fire to all other servers to ensure the task is ended there too
	local originalCaller = self.caller
	if isCaller and originalCaller then
		self:onEnded(function()
			if not originalCaller:GetAttribute("HDCallerHasInformedOthers") then
				originalCaller:SetAttribute("HDCallerHasInformedOthers", true)
				--main.services.JobService.callerLeftSender:fireOtherServers(userId)
			end
		end)
	end

	-- We end the task here when the action occurs
	-- We stack the actions in this case, because for example a player leaving will also 
	-- count as as them 'dying' or 'respawning', and a player respawning, will also count
	-- as them 'dying'
	local isDies = action == "Dies"
	local isRespawns = action == "Respawns"
	local humanoid = getHumanoid(trackingPlayer)
	if isDies or isRespawns then
		if humanoid then
			if isDies and humanoid.Health <= 0 then
				self:destroy()
			else
				self.janitor:add(humanoid.Died:Connect(function()
					if isRespawns then
						-- This is more desirable than characterAdded, because it ends
						-- the task before the character is added again, meaning the
						-- 'hasEnded' behaviour doesn't impact the new character
						local respawnTime = Players.RespawnTime-0.01
						task.wait(respawnTime)
					end
					self:destroy()
				end))  
			end
		end
	end
	if isRespawns or isDies then
		local loadCharacterStarted = require(modules.PlayerUtil.loadCharacterStarted)
		self.janitor:add(loadCharacterStarted:Connect(function(incomingPlayer)
			if incomingPlayer == trackingPlayer then
				self:destroy()
			end
		end))
		self.janitor:add(trackingPlayer.CharacterAdded:Connect(function(char)
			self:destroy()
		end))
	end
	local isLeaves = action == "Leaves"
	if isLeaves or isRespawns or isDies then
		self.janitor:add(trackingPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
			if not trackingPlayer or not trackingPlayer.Parent then
				self:destroy()
			end
		end))
	end
end

function Task.getOriginalArg(self: Task, argNameOrIndex)
	local index = tonumber(argNameOrIndex)
	if index then
		return self.originalArgReturnValuesFromIndex[index]
	end
	local argNameLower = tostring(argNameOrIndex):lower()
	local originalValue = self.originalArgReturnValues[argNameLower]
	return originalValue
end

function Task.register(self: Task, sound: Sound, soundType: registerSound.SoundType?)
	if not soundType then
		soundType = "Command"
	end
	local registerSound = require(modules.AssetUtil.registerSound)
	return registerSound(sound, soundType)
end

function Task.onEnded(self: Task, callback: () -> ())
	if self.isActive then
		self.janitor:add(callback)
	end
end

function Task.destroy(self: Task)
	if self.isActive == false then
		return
	end
	print("TASK DIED:", self.commandName)
	if isServer then
		if not endClientTask then
			endClientTask = Remote.new("EndClientTask", "Event")
		end
		for plrName, _ in self.activeClientTasks do
			local player = Players:FindFirstChild(plrName :: string)
			if not player then
				continue
			end
			if endClientTask and player:IsA("Player") then
				endClientTask:fireClient(player, self.UID)
			end
			self.activeClientTasks[plrName] = nil
		end
	end
	local function unregisterTask()
		tasks[self.UID] = nil
	end
	if self.cooldown > 0 and not self.hasCompletedCooldown then
		self.cooldownEndTime = os.clock() + self.cooldown
		task.delay(self.cooldown, function()
			self.hasCompletedCooldown = true
			unregisterTask()
		end)
	else
		unregisterTask()
	end
	self.holdsToResume = {}
	self.isActive = false
	self.janitor:destroy()
end


-- TYPES
export type TargetType = getTargets.TargetType

export type TriStateSetting = "Default" | "True" | "False"

export type Persistence =
	"UntilTargetDies" | -- Waits until the player dies or leaves before killing the task
	"UntilTargetRespawns" | -- Waits until the player respawns or leaves before killing the task
	"UntilTargetLeaves" | -- Waits until the player leaves before killing the task
	"UntilCallerDies" | -- Waits until the caller dies or leaves before killing the task
	"UntilCallerRespawns" | -- Waits until the caller respawns or leaves before killing the task
	"UntilCallerLeaves" | -- Waits until the caller (i.e. the person who executed the command) leaves before killing the task
	"Indefinitely" -- The task is only killed when :destroy is manually called (i.e. ;unCommandName), or when its associated player leaves

export type BuffPlayer = Player? | "Server"

export type BuffGroup = string -- "All" | "Player" | "Camera" | "Character" | "Humanoid" | "Outfit" | "Server" | "Map" | "Other"

export type BuffCallback = typeof(function(hasEnded: boolean, isTop: boolean)
	return
end)

export type Buff = {
	player: BuffPlayer,
	group: BuffGroup,
	priority: number,
	callback: BuffCallback,
	timeAdded: number,
	taskUID: string,
	isActive: boolean,
	destroy: (buff: Buff) -> (),
}

export type Properties = {
	UID: string?,
	callerUserId: number,
	targetUserId: number?,
	commandName: string,
	commandNameLower: string?,
	args: {[string]: {string}}?,
	modifiers: {[string]: {string}}?,
	qualifiers: {[string]: {string}}?,
	isRestricted: boolean?,
	clientArgs: {any}?,
}

export type Command = {
	name: string,
	role: string?,
	aliases: {string}?,
	undoAliases: {string}?, -- aliases to undone the command, e.g. "ice" might have "thaw"
	description: string?,
	groups: {string}?, -- all commands in the same group are *undone* when another is run
	cooldown: number?, -- if > 0, the command cannot be run again until finished and its cooldown expired
	autoPreview: boolean?, -- if true, the command is viewed first in UI (useful for ban command)
	contributors: {string}?,
	args: {Args.Argument | Args.ArgumentDetail},
	run: ((Class, {any}) -> () | any)?,
	displayName: string?, -- custom display name
	displayPrefix: string?, -- custom display prefix, useful for overrides
}

export type Commands = {Command}

export type ClientCommand = {
	--[string]: any,
	name: string,
	run: ((Class, ...any) -> () | any)?,
	replicate: (() -> ())?,
}

export type ClientCommands = {ClientCommand}

type TaskFunctions = {
    new: (Properties) -> Class,
    getTask: (string?) -> Task?,
    getTasks: (string?, number?) -> {Task},
}

type TaskMethods = {
    spawn: (callback: () -> ()) -> any,
    defer: (callback: () -> ()) -> any,
    delay: (delayTime: number, callback: () -> ()) -> any,
    wait: (yieldTime: number?) -> any,
    iterate: (iterations: number, callback: (i: number) -> ()) -> any,
    loop: (callback: (stop: () -> (), i: number) -> ()) -> any,
    pause: (self: Class) -> any,
    resume: (self: Class) -> any,
	buff: (self: Class, player: BuffPlayer, buffGroup: BuffGroup, priorityOrCallback: number | BuffCallback, callback: BuffCallback?) -> any,
    keep: (self: Class, persistence: Persistence) -> any,
    getOriginalArg: (self: Class, argNameOrIndex: string | number) -> any,
    onEnded: (self: Class, callback: () -> ()) -> any,
    destroy: (self: Class) -> any,
}

type TaskProperties = {
	janitor: typeof(Janitor.new()),
	UID: string,
	isActive: boolean,
	caller: Player?,
	target: Player?,
	client: TaskClient.Class,
	server: TaskServer.Class,
}

export type Class = TaskMethods & TaskProperties

export type Task = typeof(Task.construct(...))


return Task :: TaskFunctions