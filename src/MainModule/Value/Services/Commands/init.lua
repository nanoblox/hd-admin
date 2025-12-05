--!strict
-- CONFIG
local MAXIMUM_REQUEST_PER_SECOND = 20 -- Maximum size of a single command request (in characters) which overrides ``settings.Limits.RequestsPerSecond`` if greater than
local CLIENT_PROPERTIES_TO_EXCLUDE = {
	"run",
	"creationOrder",
	"order",
}

local CLIENT_PROPERTIES_TO_PREVIEW = {
	"name",
	"key",
	"prefix",
	"hide",
}


-- LOCAL
local Commands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local parser = modules.Parser
local User = require(modules.Objects.User)
local ParserTypes = require(parser.ParserTypes)
local Config = require(modules.Parent.Services.Config)
local Task = require(modules.Objects.Task)
local commandsArray: Task.Commands = {}
local keyToCommand: {[string]: Command} = {}
local lowerCaseNameAndAliasCommandsDictionary: {[string]: Command} = {}
local sortedNameAndAliasWithOverrideLengthArray: {string} = {}
local commandsRequireUpdating = true
local commandPrefixes: {[string]: boolean} = {}



-- TYPES
export type MessageSource = "Chat" | "ChatCommand" | "Script" | "ClientCommandBar" | "ClientPreviewRun" | "ClientRun" | "ClientCommand" | "Other" | "Unknown"
type User = User.Class
type Batch = ParserTypes.ParsedBatch
type Statement = ParserTypes.ParsedStatement
type ArgGroup = {[string]: {string}}
type Task = Task.Class
type Command = Task.Command -- Moved under 'Task' to prevent cyclical warning
type ClientCommand = Task.ClientCommand -- Moved under 'Task' to prevent cyclical warning
type TriStateSetting = Task.TriStateSetting
type Properties = Task.Properties


-- FUNCTIONS
function Commands.updateCommands()
	if not commandsRequireUpdating then
		return false
	end
	commandsRequireUpdating = false
	commandsArray = {}
	keyToCommand = {}
	lowerCaseNameAndAliasCommandsDictionary = {}
	sortedNameAndAliasWithOverrideLengthArray = {}
	commandPrefixes = {}
	local forEveryCommand = require(modules.CommandUtil.forEveryCommand)
	local creationOrder = 0
	for _, commandModule in pairs(script:GetChildren()) do
		if not commandModule:IsA("ModuleScript") then
			continue
		end
		local commandsInside = require(commandModule) :: any
		local rolesToAdd = commandModule:GetAttribute("RolesToAdd")
		local rolesArray = if typeof(rolesToAdd) == "string" then string.split(rolesToAdd, " ||| ") else {}
		if rolesToAdd then
			commandModule:SetAttribute("RolesToAdd", nil)
		end
		forEveryCommand(commandsInside, function(command: any)
			local prefixes = command.prefixes
			local commandName = command.name
			if typeof(commandName) ~= "string" then
				return
			end

			-- Add roles from the Config roles the command was originally under
			if rolesToAdd then
				local newRoles = {}
				for _, item in rolesArray do
					-- Add the primary (config) roles first
					table.insert(newRoles, item)
				end
				if typeof(command.roles) == "table" then
					for _, item in command.roles do
						-- Add the already existing roles second
						table.insert(newRoles, item)
					end
				end
				command.roles = newRoles
			end
			
			-- If command contains a custom prefix
			local commandNameLower = commandName:lower()
			if typeof(prefixes) == "table" then
				for _, prefix in prefixes do
					if typeof(prefix) == "string" then
						commandPrefixes[prefix] = true
					end
				end
			end
			creationOrder += 1
			command.creationOrder = creationOrder
			command.name = commandName
			command.key = commandNameLower
			table.insert(commandsArray, command :: Command)
			keyToCommand[commandNameLower] = command
			local function registerNameOrAlias(nameOrAlias: string?, isOverride: boolean?)
				if typeof(nameOrAlias) ~= "string" then
					return false
				end
				local writeTo = lowerCaseNameAndAliasCommandsDictionary
				local nameOrAliasLower = nameOrAlias:lower()
				local firstTime = writeTo[nameOrAliasLower] == nil
				if not isOverride then
					writeTo[nameOrAliasLower] = command
				end
				if firstTime then
					table.insert(sortedNameAndAliasWithOverrideLengthArray, nameOrAliasLower)
				end
				return true
			end
			registerNameOrAlias(commandName)
			local function registerAliases(array, isOverride)
				if typeof(array) == "table" then
					for _, alias in array do
						if isOverride then
							local overrideAlias = string.sub(alias, 2)
							alias = overrideAlias
						end
						registerNameOrAlias(alias, isOverride)
					end
				end
			end
			registerAliases(command.aliases)
			registerAliases(command.undoAliases)
			-- If command is an override (e.g. it's name contains a validPrefix, e.g. /helicopter)
			local firstChar = string.sub(commandName, 1, 1)
			local isValidPrefix = require(modules.CommandUtil.isValidPrefix)
			if isValidPrefix(firstChar) then
				local overrideName = string.sub(commandName, 2)
				commandPrefixes[firstChar] = true
				command.prefix = firstChar
				command.name = overrideName
				registerNameOrAlias(overrideName, true) -- Also register override so that it can be detected in parser
				registerAliases(command.aliases, true) -- Same as line above, register for parser
			end
		end)
	end
	table.sort(sortedNameAndAliasWithOverrideLengthArray, function(a: string, b: string): boolean
		if #a == #b then
			return a < b
		end
		return #a > #b
	end)
	table.sort(commandsArray, function(commandA: any, commandB: any)
		local orderA = commandA.order or 0
		local orderB = commandB.order or 0
		if orderA == orderB then
			local internalOrderA = commandA.creationOrder or 0
			local internalOrderB = commandB.creationOrder or 0
			return internalOrderA < internalOrderB
		end
		return orderA < orderB
	end)
	for i, command in commandsArray do
		command.index = i
	end
	User.everyone:set("Commands", commandsArray)
	User.everyone:set("CommandInfo", keyToCommand)
	return true
end

function Commands.getCommand(keyOrNameOrAlias: string, overridePrefix: string?): (Command?, boolean?)
	Commands.updateCommands()
	local lowerNameOrAlias = keyOrNameOrAlias:lower()
	local command = lowerCaseNameAndAliasCommandsDictionary[lowerNameOrAlias] :: Command?
	if not command and typeof(overridePrefix) == "string" and #overridePrefix == 1 then
		local newAlias = overridePrefix..lowerNameOrAlias
		command = lowerCaseNameAndAliasCommandsDictionary[newAlias] :: Command?
		return command, true
	end
	return command, false
end

function Commands.getCommandsArray()
	Commands.updateCommands()
	return commandsArray
end

function Commands.getSortedNameAndAliasLengthArray()
	Commands.updateCommands()
	return sortedNameAndAliasWithOverrideLengthArray
end

function Commands.getCommandPrefixes()
	Commands.updateCommands()
	return commandPrefixes
end

function Commands.request(user: User.Class, message: string, messageSource: MessageSource?): (boolean, {any}, {Task})
	-- It's essential that in addition to checking the maximum commands a player can use, that
	-- we also check the maximum requests they are making too, so to avoid malicious spamming
	-- of messages which could overwhelm the parser (e.g. 100,000 characters every milisecond).
	-- If detected, we simply ignore the message from that user.
	if not messageSource then
		messageSource = "Unknown" :: MessageSource
	end
	local getDataSize = require(modules.VerifyUtil.getDataSize)
	local bypassLimits = false --!!! roles: CHECK IF USER ROLES
	local limits = Config.getSetting("Limits")
	local maxRequestSize = limits.RequestSize
	local maxRequestsPerSecond = if bypassLimits then MAXIMUM_REQUEST_PER_SECOND else math.min(limits.RequestsPerSecond, MAXIMUM_REQUEST_PER_SECOND)
	local messageSize = getDataSize(message)
	if not bypassLimits and messageSize > maxRequestSize then
		return false, {{false, `Request exceeded max size of {maxRequestSize} characters!`}}, {}
	end
	local requestsThisSecond = user.temp:get("RequestsThisSecond")
	local requestsThisSecondStartClock = user.temp:get("RequestsThisSecondStartClock")
	local clockNow = os.clock()
	if clockNow - requestsThisSecondStartClock >= 1 then
		requestsThisSecond = 0
		requestsThisSecondStartClock = clockNow
		user.temp:set("RequestsThisSecond", requestsThisSecond)
		user.temp:set("RequestsThisSecondStartClock", requestsThisSecondStartClock)
	end
	local newRequestsThisSecond = requestsThisSecond + 1
	if not bypassLimits and newRequestsThisSecond > maxRequestsPerSecond then
		return false, {{false, `Request rate exceeded max of {maxRequestsPerSecond} requests per second!`}}, {}
	end
	user.temp:set("RequestsThisSecond", newRequestsThisSecond)
	--
	local Parser = require(modules.Parser) :: any -- 'Any' to remove cyclic warning
	local batch = Parser.parse(message, user)
	local approved, notices, tasks = Commands.processBatchAsync(user, batch)
	if not tasks then
		tasks = {}
	end
	--
	return approved, notices, tasks :: {Task}
end

function Commands.processNotices(notices: {any})
	for _, noticeTable in notices do
		local isWarning = noticeTable[1] == false
		local string = noticeTable[2]
		local initial = `[HD Admin {isWarning and "WARNING" or "Notice"}]: `
		warn(initial..string)
	end
end

function Commands.processStatementAsync(callerUser: User, statement: Statement): (boolean, string | {Task})
	-- This verifies and executes the statement (if permitted)
	local approved, warning = Commands.verifyStatementAsync(callerUser, statement)
	if not approved then
		return false, (warning or "Statement denied")
	end
	local callerUserId = callerUser.userId :: number
	local tasks = Commands.executeStatement(callerUserId, statement)
	return true, tasks
end

function Commands.processBatchAsync(callerUser: User, batch: Batch): (boolean, {any}, {Task}?)
	-- This verifies and executes the statements within the batch (if permitted)
	if type(batch) ~= "table" then
		return false, {{false, "The batch must be a table!"}}, nil
	end
	local collectiveTasks: {any} = {}
	local collectiveNotices = {}
	local atLeastOneSuccess = false
	for _, statement in batch do
		local success, tasksOrWarning = Commands.processStatementAsync(callerUser, statement)
		if success and typeof(tasksOrWarning) == "table" then
			for _, task in tasksOrWarning do
				atLeastOneSuccess = true
				table.insert(collectiveTasks, task)
			end
		end
		if not success and typeof(tasksOrWarning) == "string" then
			table.insert(collectiveNotices, {false, tasksOrWarning})
			break -- After any failures, stop processing further statements to avoid spam
		end
	end
	return atLeastOneSuccess, collectiveNotices, collectiveTasks :: {Task}
end

function Commands.verifyStatementAsync(user: User, statement: Statement)--: (approved: boolean, reason: string?)
	
	-- Was the statement rejected during parsing?
	if statement.isValid ~= true then
		return false, statement.errorMessage
	end

	-- Ensure statement is converted
	local ParserUtility = require(parser.ParserUtility)
	ParserUtility.convertStatementToRealNames(statement)

	-- Is user still active?
	local callerUserId = user.userId :: number
	if not user.isActive then
		return false, "User hasn't loaded yet!"
	end

	-- Ensure commands exists and add up total
	local statementCommands = statement.commands
	local statementModifiers = statement.modifiers
	local statementQualifiers = statement.qualifiers
	local totalCommands = 0
	if not statementCommands then
		return false, "Failed to execute command as it does not exist!"
	end
	for commandName, arguments in statementCommands do
		local command = Commands.getCommand(commandName) :: Command?
		if not command or typeof(command.args) ~= "table" then
			continue
		end
		totalCommands += 1
	end

	-- Block the command from running if a cooldown is already active
	local warningNotice
	local forEveryPotentialTask = require(modules.CommandUtil.forEveryPotentialTask)
	forEveryPotentialTask(callerUserId, statement, function(command: Command, arguments, optionalTargetUserId: number?)
		local commandKey = command.key
		local commandName = command.name
		local runningTasks = Task.getTasks(commandKey, optionalTargetUserId)
		local hasACooldown = typeof(command.cooldown) == "number" and command.cooldown > 0
		if hasACooldown and #runningTasks > 0 and not statementModifiers.undo then
			local activeTask = runningTasks[1]
			local endTime = activeTask.cooldownEndTime
			local additionalUserMessage = ""
			local associatedPlayer = activeTask.target
			if associatedPlayer then
				additionalUserMessage = ` on {associatedPlayer.DisplayName} (@{associatedPlayer.Name})`
			end
			if endTime then
				local remainingTime = (math.ceil((endTime-os.clock())*100))/100
				warningNotice = `Wait {remainingTime} seconds until using '{commandName}' again{additionalUserMessage}!`
			else
				warningNotice = `Wait until '{commandName}' has finished{additionalUserMessage} before using again!`
			end
			return false
		end
		return true
	end)
	if warningNotice then
		return false, warningNotice
	end

	-- Ensures commands per 1 second limit is not exceeded
	local bypassLimits = false --!!! roles: CHECK IF USER ROLES
	local limits = Config.getSetting("Limits")
	local maxCommandsPerMinute = limits.CommandsPerMinute
	local maxCommandsPer1Second = math.floor(maxCommandsPerMinute / 6)
	local commandsThisSecond = user.temp:get("CommandsThisSecond")
	local commandsThisSecondStartClock = user.temp:get("CommandsThisSecondStartClock")
	local clockNow = os.clock()
	if clockNow - commandsThisSecondStartClock >= 1 then
		commandsThisSecond = 0
		commandsThisSecondStartClock = clockNow
		user.temp:set("CommandsThisSecond", commandsThisSecond)
		user.temp:set("CommandsThisSecondStartClock", commandsThisSecondStartClock)
	end
	local newComandsThisSecond = commandsThisSecond + totalCommands
	if not bypassLimits and newComandsThisSecond > maxCommandsPer1Second then
		return false, `Exceeded {maxCommandsPer1Second} commands per second. Send less and try again.`
	end

	-- Ensures commands per 60 and 20 second limits are not exceeded
	local maxCommandsPer20Seconds = math.floor(maxCommandsPerMinute / 2)
	local commandsThisMinute = user.perm:get("CommandsThisMinute")
	local commandsThisMinuteStartStamp = user.perm:get("CommandsThisMinuteStartStamp")
	local timeNow = os.time()
	if timeNow - commandsThisMinuteStartStamp >= 60 then
		commandsThisMinute = 0
		commandsThisMinuteStartStamp = timeNow
		user.perm:set("CommandsThisMinute", commandsThisMinute)
		user.perm:set("CommandsThisMinuteStartStamp", commandsThisMinuteStartStamp)
	end
	local timeSoFar = timeNow - commandsThisMinuteStartStamp
	local cooldownAmount = commandsThisMinuteStartStamp + 60 - timeNow
	local newComandsThisMinute = commandsThisMinute + totalCommands
	if not bypassLimits then
		if newComandsThisMinute > maxCommandsPerMinute then
			return false, `Exceeded {maxCommandsPerMinute} commands per minute. Wait {cooldownAmount}s to send again.`
		end
		if timeSoFar <= 20 and newComandsThisMinute > maxCommandsPer20Seconds then
			cooldownAmount -= 40
			return false, `Exceeded {maxCommandsPer20Seconds} commands per 20s. Wait {cooldownAmount}s to send again.`
		end
	end

	--[[
	-- argItem.verifyCanUse can sometimes be asynchronous therefore we name this an async function
	local approved = true
	local details = {}
	local callerUserId = callerUser.userId

	if typeof(statement) ~= "table" then
		return false, "Statement must be a statement table!"
	end
	--ParserUtility.convertStatementToRealNames(statement) -- Don't do anymore
	
	local statementCommands = statement.commands
	local modifiers = statement.modifiers
	local qualifiers = statement.qualifiers
	
	if not statementCommands then
		return false, "Failed to execute command as it does not exist!"
	end

	-- This verifies the caller can use the given commands and associated arguments
	for commandName, arguments in pairs(statementCommands) do
		
		-- If arguments is not a table, convert to one
		if typeof(arguments) ~= "table" then
			arguments = {}
			statementCommands[commandName] = arguments
		end

		-- Does the command exist
		local command = Commands.getCommand(commandName)
		if not command then
			return false, `'{commandName}' is not a valid command!`
		end

		-- Does the caller have permission to use it
		local commandNameLower = string.lower(commandName)
		if not RoleService.verifySettings(callerUser, "commands").have(commandNameLower) then
			--!!! RE_ENABLE THIS
			--[[return resolve(false, {{"notice", {
				text = string.format("You do not have permission to use command '%s'!", commandName),
				error = true,
			}}})
			return--
		end

		-- Does the caller have permission to target multiple players
		local targetPlayers = Args.get("player"):parse(statement.qualifiers, callerUserId)
		if RoleService.verifySettings(callerUser, "limit.whenQualifierTargetCapEnabled").areAll(true) then
			local limitAmount = RoleService.getMaxValueFromSettings(callerUser, "limit.qualifierTargetCapAmount")
			if #targetPlayers > limitAmount then
				local finalMessage
				if limitAmount == 1 then
					finalMessage = ("1 player")
				else
					finalMessage = string.format("%s players", limitAmount)
				end
				return resolve(false, {{"notice", {
					text = string.format("You're only permitted to target %s per statement!", finalMessage),
					error = true,
				}}})
			end
		end

		-- Does the caller have permission to use the associated arguments of the command
		local argStringIndex = 0
		for _, argNameOrAliasOrDetail in command.args do
			local argItem = Args.get(argNameOrAliasOrDetail)
			if argStringIndex == 0 and argItem.playerArg then
				continue
			end
			argStringIndex += 1
			local argString = arguments[argStringIndex]
			if argItem.verifyCanUse and not (modifiers.undo or modifiers.preview) then
				local canUseArg, deniedReason = argItem:verifyCanUse(callerUser, argString, {argNameOrAlias = argNameOrAlias})
				if not canUseArg then
					return resolve(false, {{"notice", {
						text = deniedReason,
						error = true,
					}}})
				end
			end
		end

	end

	-- This adds an additional notification if global as these commands can take longer to execute
	if modifiers and modifiers.global then
		table.insert(details, {"notice", {
			text = "Executing global command...",
			error = false,
		}})
	end
	
	resolve(approved, details)
	
	return promise:andThen(function(approved, noticeDetails)
		-- This fires off any notifications to the caller
		local callerPlayer = callerUser.player
		if callerPlayer then
			for _, detail in pairs(noticeDetails) do
				local method = main.services.MessageService[detail[1]] --[[
				method(callerPlayer, detail[2])
			end
		end
		return approved, noticeDetails
	end)
	--]]
	
	-- Now actually set when success
	user.temp:set("CommandsThisSecond", newComandsThisSecond)
	user.perm:set("CommandsThisMinute", newComandsThisMinute)

	return true, nil
end

function Commands.executeStatement(callerUserId: number, statement: Statement): {Task}

	-- Ensure statement is converted
	local ParserUtility = require(parser.ParserUtility)
	ParserUtility.convertStatementToRealNames(statement)

	-- This enables restrictions to be bypassed if customized
	-- This is useful for fake server users for example
	if statement.isRestricted == nil then
		local callerUser = User.getUserByUserId(callerUserId)
		statement.isRestricted = true :: any
		if callerUser then
			--statement.isRestricted = not main.services.RoleService.verifySettings(callerUser, "ignore.roleRestrictions").areSome(true)
		end
	end
	
	-- If 'player' instance detected within qualifiers, convert to player.Name
	local ParserTypes = require(parser.ParserTypes)
	local ConfigSettings = require(modules.Parent.Services.Config.Settings)
	for qualifierKey, qualifierTable in pairs(statement.qualifiers) do
		if typeof(qualifierKey) == "Instance" and qualifierKey:IsA("Player") then
			local callerUser = User.getUserByUserId(callerUserId)
			local playerDefinedSearch: ConfigSettings.PlayerSearch = Config.getSetting("PlayerDefinedSearch", callerUser)
			local playerName = qualifierKey.Name
			if playerDefinedSearch == "UserName" or playerDefinedSearch == "UserNameAndDisplayName" then
				local playerIdentifier = Config.getSetting("PlayerIdentifier", callerUser)
				playerName = tostring(playerIdentifier)..playerName
			end
			statement.qualifiers[qualifierKey] = nil
			statement.qualifiers[playerName] = qualifierTable
		end
	end

	-- This enables the preview modifier if command.autoPreview is true
	-- or bypasses the preview modifier entirely if the request is from the client
	if statement.isFromClient then
		statement.modifiers.preview = nil
	else
		for commandName, arguments in pairs(statement.commands) do
			local command = Commands.getCommand(commandName)
			local previewModifier = statement.modifiers.preview :: any
			if command and command.autoPreview == true and previewModifier ~= false then
				statement.modifiers.preview = true :: any
				break
			end
		end
	end

	-- This handles any preActions within present modifiers
	-- Also, if the modifier preAction value returns false then cancel the execution
	local Modifiers = require(parser.Modifiers) :: any -- 'Any' to remove cyclic warning
	for modifierName, _ in pairs(statement.modifiers) do
		local modifierItem = Modifiers.get(modifierName)
		if modifierItem then
			local continueExecution = modifierItem.preAction(callerUserId, statement)
			if not continueExecution then
				return {}
			end
		end
	end

	-- Define the properties that we'll create the task from arguments
	local Args = require(parser.Args)
	local tasks: {any} = {}
	local isPermModifier = statement.modifiers.perm
	local isGlobalModifier = statement.modifiers.wasGlobal
	local qualifiers = (statement.qualifiers or {}) :: ArgGroup
	local modifiers = (statement.modifiers or {}) :: ArgGroup
	local generateUID = require(modules.DataUtil.generateUID)
	local taskUID = statement.taskUID or generateUID(10)

	-- Tasks are split into separate players (such as those with the 'Player' arg),
	-- while some do not (such as those with the 'Players' arg, or without any type
	-- of player arg at all)
	-- For more details, see module 'forEveryPotentialTask'
	local forEveryPotentialTask = require(modules.CommandUtil.forEveryPotentialTask)
	forEveryPotentialTask(callerUserId, statement, function(command: Command, arguments, optionalTargetUserId: number?)
		
		-- Setup task properties
		local commandKey = command.key :: string
		local args = (arguments or {}) :: ArgGroup
		local properties: Properties = {
			callerUserId = callerUserId,
			targetUserId = optionalTargetUserId,
			commandKey = commandKey,
			args = args,
			modifiers = modifiers,
			qualifiers = qualifiers,
			isRestricted = statement.isRestricted,
			UID = taskUID,
		}
		
		-- Undo tasks if already applied to player (or server level)
		local runningTasks = Task.getTasks(commandKey, optionalTargetUserId)
		local hasACooldown = typeof(command.cooldown) == "number" and command.cooldown > 0
		if not hasACooldown then
			for _, task in pairs(runningTasks) do
				task:destroy()
			end
		end
		
		-- Undo tasks if they contain the same group as any groups from this command
		local ourGroups = command.groups
		if optionalTargetUserId and typeof(ourGroups) == "table" then
			local allPlayerTasks = Task.getTasks(nil, optionalTargetUserId)
			for _, task in allPlayerTasks do
				local dictOfGroupsLower = task.dictOfGroupsLower
				for _, groupName in ourGroups do
					local nameLower = string.lower(groupName)
					if dictOfGroupsLower[nameLower] then
						task:destroy()
						break
					end
				end
			end
		end

		-- Finally all good, now create task
		local task = Task.new(properties)
		if task then
			table.insert(tasks, task)
		end

		return true
	end)

	return tasks :: {Task}
end


-- SETUP
-- These set restrictions on what the client can see, and which clients
local getStateVerifier = require(modules.VerifyUtil.getStateVerifier)
User.everyone:verify(getStateVerifier(
	"Commands",
	"OnlyInclude",
	CLIENT_PROPERTIES_TO_PREVIEW
))
User.everyone:verify(getStateVerifier(
	"CommandInfo",
	"Exclude",
	CLIENT_PROPERTIES_TO_EXCLUDE
))


-- This is essential to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.verifyFirstFetch("Commands", Commands.updateCommands)
State.verifyFirstFetch("CommandInfo", Commands.updateCommands)


return Commands