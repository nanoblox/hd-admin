--[[

	Modifiers are items that can be applied to statements to enhance a commands default behaviour
	For example, to execute a command in *every* server, you could add the 'global' modifier to a command:
	``;globalNotice all Greetings!``
	They are split into two groups:
		1. PreAction Modifiers - these execute before a task is created and can block the task being created entirely
		2. Action Modifiers - these execute while a task is running and can extend the longevity of the task

	To do:
		1. Explore:
			executeRightAway = true,
			executeAfterThread = false,
			yieldUntilThreadComplete = false,
		2. Re-write for v2
]]


--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Modifiers = {}
local Players = game:GetService("Players")
local ParserTypes = require(modules.Parser.ParserTypes)
local requiresUpdating = true
local sortedNameAndAliasLengthArray = {}
local lowerCaseDictionary = {}


-- LOCAL FUNCTIONS
local function register(item: ModifierDetail): ModifierDetail
	return item :: ModifierDetail -- We do this to support type checking within the table
end


-- FUNCTIONS
function Modifiers.update()
	if not requiresUpdating then
		return false
	end
	requiresUpdating = false
	local allItems = Modifiers.getAll()
	sortedNameAndAliasLengthArray = {}
	lowerCaseDictionary = {}
	for itemNameOrAlias, item in pairs(allItems :: any) do
		local lowerCaseName = tostring(itemNameOrAlias):lower()
		lowerCaseDictionary[lowerCaseName] = item
		table.insert(sortedNameAndAliasLengthArray, tostring(itemNameOrAlias))
	end
	table.sort(sortedNameAndAliasLengthArray, function(a: string, b: string): boolean
		return #a > #b
	end)
	return true
end

function Modifiers.getSortedNameAndAliasLengthArray()
	Modifiers.update()
	return sortedNameAndAliasLengthArray
end

function Modifiers.getLowercaseDictionary()
	Modifiers.update()
	return lowerCaseDictionary
end

function Modifiers.get(modifierKey: Modifier): ModifierDetail?
	local modifierKeyLower = tostring(modifierKey):lower()
	local ourDictionary = Modifiers.getLowercaseDictionary()
	local item = ourDictionary[modifierKeyLower] :: ModifierDetail?
	if not item then
		return nil
	end
	local modifierKeyCorrected = item.key
	if item.mustCreateAliasOf then
		local toCreateName = item.mustCreateAliasOf
		local qualifierToCreate = Modifiers.items[toCreateName]
		if not qualifierToCreate then
			error(`Modifiers: {modifierKeyCorrected} can not create alias because {toCreateName} is not a valid qualifier`)
		end
		qualifierToCreate = qualifierToCreate :: any
		for k,v in qualifierToCreate do
			item = item :: any
			if not item[k] then
				item[k] = v
			end
		end
		item.mustCreateAliasOf = nil :: any
		item.aliasOf = toCreateName
	end
	return item :: ModifierDetail
end

function Modifiers.getAll()
	-- We call .get to ensure all aliases are registered and setup correctly
	local items = Modifiers.items :: any
	for modifierKey, item in items do
		if not item.key then
			item.key = modifierKey
		end
		Modifiers.get(modifierKey :: Modifier)
	end
	return items :: {[string]: ModifierDetail} --:: {[Modifier]: ModifierDetail}
end

function Modifiers.createAliasOf(modifierKey: Modifier, initialTable: any?)
	-- We don't actually create a mirror table here as the data of items will have
	-- not yet gone into memory. Instead, we record the table as an alias, then
	-- set it's data once .get is called or 
	task.defer(function()
		-- This servers as a warning as opposed to an actual error
		if not Modifiers.items[modifierKey] then
			error(`Modifiers: {modifierKey} is not a valid qualifier`)
		end
	end)
	if typeof(initialTable) ~= "table" then
		initialTable = {}
	end
	initialTable.mustCreateAliasOf = modifierKey
	return initialTable
end


-- PUBLIC
Modifiers.items = {
	
	["Preview"] = register({
		description = "Displays a menu that previews the command instead of executing it.",
		preAction = function(callerUserId: number, statement: Statement)
			local caller = Players:GetPlayerByUserId(callerUserId)
			if caller then
				--!!! Have remote fire to player to open preview menu
				return true
			end
			return false
		end,
	}),

	["Random"] = register({
		description = "Randomly selects a command within a statement. All other commands are discarded.",
		preAction = function(_, statement)
			local commands = statement.commands
			if #commands > 1 then
				local randomIndex = math.random(1, #commands)
				local selectedItem = commands[randomIndex]
				commands = { selectedItem }
				statement.commands = commands
			end
			return true
		end,
	}),

	["Perm"] = register({
		description = "Permanently saves the task. This means in addition to the initial execution, the command will be executed whenever a server starts, or if player specific, every time the player joins a server.",
		preAction = function(_, statement)
			local modifiers = statement.modifiers
			local oldGlobal = modifiers.global
			if oldGlobal then
				--!! Complete this later
				-- Its important to ignore the global modifier in this situation as setting Task to
				-- perm storage achieves the same effect. Merging both together however would create
				-- a vicious infinite cycle
				modifiers.global = nil
				modifiers.wasGlobal = oldGlobal :: any
			end
			return true
		end,
	}),

	["Global"] = register({
		description = "Broadcasts the task to all servers.",
		preAction = function(callerUserId: number, statement: Statement)
			--!! Complete this later
			--[[
			local CommandService = main.services.CommandService
			local modifiers = statement.modifiers
			local oldGlobal = modifiers.global
			modifiers.global = nil
			modifiers.wasGlobal = oldGlobal
			CommandService.executeStatementGloballySender:fireAllServers(callerUserId: number, statement: Statement)
			--]]
			return false
		end,
	}),

	["Undo"] = register({
		description = "Ends all Tasks that match the given command name(s). To end a task across all servers, the 'global' modifier must be included.",
		preAction = function(callerUserId: number, statement: Statement)
			local Commands = require(services.Commands)
			local Args = require(script.Parent.Args)
			for commandName, _ in statement.commands do
				local command = Commands.getCommand(commandName)
				if not command then
					continue
				end
				local firstCommandArg = command.args[1]
				local firstArgItem = Args.get(firstCommandArg :: any)
				local function endTasks(playerUserId: number?)
					local Task = require(modules.Objects.Task)
					local runningTasks = Task.getTasks(commandName, playerUserId)
					for _, task in runningTasks do
						task:destroy()
					end
				end
				if firstArgItem and firstArgItem.playerArg and firstArgItem.runForEachPlayer then
					local playerArg = Args.get("Player")
					local targets = (playerArg and playerArg:parse(statement.qualifiers, callerUserId)) or {}
					for _, plr in targets do
						endTasks(plr.UserId)
					end
				else
					endTasks()
				end
			end
			return false
		end,
	}),

	["Un"] = Modifiers.createAliasOf("Undo"),

	["Epoch"] = register({
		description = "Waits until the given epoch time before executing. If the epoch time has already passed, the command will be executed right away. Combine with 'global' and 'perm' for a permanent game effect. Example: ``;globalPermEpoch(3124224000)message(green) Happy new year!``",
		isCustomizable = true,
		executeRightAway = false,
		executeAfterThread = true,
		yieldUntilThreadComplete = true,
		requiresCapsule = true,
		action = function(task, values)
			--!! Complete this later
			--[[
			local executionTime = unpack(values)
			local timeNow = os.time()
			local newExecutionTime = tonumber(executionTime) or timeNow + 1
			local seconds = newExecutionTime - timeNow
			local thread = main.modules.Thread.delay(seconds)
			return thread
			--]]
		end,
	}),

	["Delay"] = register({
		description = "Waits x amount of time before executing the command. Time can be represented in seconds as 's', minutes as 'm', hours as 'h', days as 'd', weeks as 'w' and years as 'y'. Example: ``;delay(3s)kill all``.",
		isCustomizable = true,
		executeRightAway = false,
		executeAfterThread = true,
		yieldUntilThreadComplete = true,
		requiresCapsule = true,
		action = function(task, values)
			--!! Complete this later
			--[[
			local timeDelay = unpack(values)
			local seconds = main.modules.DataUtil.convertTimeStringToSeconds(timeDelay)
			local thread = main.modules.Thread.delay(seconds)
			return thread
			--]]
		end,
	}),

	["Loop"] = register({
		description = "Repeats a command for x iterations every y time delay. If not specified, x defaults to ∞ and y to 1s. Time can be represented in seconds as 's', minutes as 'm', hours as 'h', days as 'd', weeks as 'w' and years as 'y'. Example: ``;loop(50,1s)jump me``.",
		isCustomizable = true,
		executeRightAway = true,
		executeAfterThread = false,
		yieldUntilThreadComplete = false,
		requiresCapsule = true,
		action = function(task, values)
			local iterations, interval = unpack(values)
			local ITERATION_LIMIT = 10000
			local MINIMUM_INTERVAL = 0.1
			local newInterations = tonumber(iterations) or ITERATION_LIMIT
			if newInterations > ITERATION_LIMIT then
				newInterations = ITERATION_LIMIT
			end
			local newInterval = tonumber(interval) or MINIMUM_INTERVAL
			if newInterval < MINIMUM_INTERVAL then
				newInterval = MINIMUM_INTERVAL
			end
			--!! Complete this later
			--[[
			local thread = main.modules.Thread.loopFor(newInterval, newInterations, task.execute, task)
			return thread
			--]]
		end,
	}),

	["Spawn"] = register({
		description = "Executes the command every time the given player(s) respawn (in addition to the initial execution). This modifier only works for commands with player-related arguments.",
		executeRightAway = true,
		executeAfterThread = false,
		yieldUntilThreadComplete = false,
		action = function(task)
			--!! Complete this later
			--[[
			local targetUser = main.modules.UserStore:getUserByUserId(task.userId)
			local targetPlayer = targetUser and targetUser.player
			if targetPlayer then
				task.persistence = main.enum.Persistence.UntilLeave
				task.janitor:add(targetPlayer.CharacterAdded:Connect(function(char)
					main.RunService.Heartbeat:Wait()
					char:WaitForChild("HumanoidRootPart")
					char:WaitForChild("Humanoid")
					task:execute()
				end), "Disconnect")
				local thread = main.modules.Thread.loopUntil(0.1, function()
					return targetUser.isDestroyed == true
				end)
				return thread
			end
			--]]
		end,
	}),

	["Expire"] = register({
		description = "Revokes the command after its first execution plus the given time. Time can be represented in seconds as 's', minutes as 'm', hours as 'h', days as 'd', weeks as 'w' and years as 'y'. Example: ``;expire(2m30s)mute player``.",
		isCustomizable = true,
		executeRightAway = true,
		executeAfterThread = false,
		yieldUntilThreadComplete = false,
		requiresCapsule = true,
		action = function(task, values)
			--!! Complete this later
			--[[
			local timeDelay = unpack(values)
			local seconds = main.modules.DataUtil.convertTimeStringToSeconds(timeDelay)
			local thread = main.modules.Thread.delay(seconds, task.kill, task)
			return thread
			--]]
		end,
	}),

	["Until"] = Modifiers.createAliasOf("Expire"),

}


-- TYPES
type Statement = ParserTypes.ParsedStatement
export type Modifier = keyof<typeof(Modifiers.items)>
export type ModifierDetail = {
	description: string,
	aliases: {[Modifier]: boolean}?,
	key: string?,
	mustCreateAliasOf: any?,
	aliasOf: string?,
	requiresCapsule: boolean?,
}


return Modifiers