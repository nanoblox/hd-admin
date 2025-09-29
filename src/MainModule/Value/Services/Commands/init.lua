--!strict
-- LOCAL
local Commands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local parser = modules.Parser
local User = require(modules.Objects.User)
local ParserTypes = require(parser.ParserTypes)
local Config = require(modules.Config)
local Task = require(modules.Objects.Task)
local commandsArray: Task.Commands = {}
local lowerCaseNameAndAliasCommandsDictionary: {[string]: Command} = {}
local sortedNameAndAliasWithOverrideLengthArray: {string} = {}
local commandsRequireUpdating = true
local commandPrefixes: {[string]: boolean} = {}


-- TYPES
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
	lowerCaseNameAndAliasCommandsDictionary = {}
	sortedNameAndAliasWithOverrideLengthArray = {}
	commandPrefixes = {}
	local forEveryCommand = require(modules.CommandUtil.forEveryCommand)
	for _, commandModule in pairs(script:GetChildren()) do
		if not commandModule:IsA("ModuleScript") then
			continue
		end
		local commandsInside = require(commandModule) :: any
		forEveryCommand(commandsInside, function(command: any)
			local prefixes = command.prefixes
			local commandName = command.name
			-- If command contains a custom prefix
			if typeof(prefixes) == "table" then
				for _, prefix in prefixes do
					if typeof(prefix) == "string" then
						commandPrefixes[prefix] = true
					end
				end
			end
			table.insert(commandsArray, command :: Command)
			local function registerNameOrAlias(nameOrAlias: string, isOverride: boolean?)
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
			local function registerAliases(array)
				if typeof(array) == "table" then
					for _, alias in array do
						registerNameOrAlias(alias)
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
				registerNameOrAlias(overrideName, true) -- Also register override so that it can be detected in parser
			end
		end)
	end
	table.sort(sortedNameAndAliasWithOverrideLengthArray, function(a: string, b: string): boolean
		return #a > #b
	end)
	return true
end

function Commands.getCommand(nameOrAlias: string, overridePrefix: string?): (Command?, boolean?)
	Commands.updateCommands()
	local lowerNameOrAlias = nameOrAlias:lower()
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

function Commands.processStatementAsync(callerUser: User, statement: Statement): (boolean, string | {Task})
	-- This verifies and executes the statement (if permitted)
	local ParserUtility = require(parser.ParserUtility)
	ParserUtility.convertStatementToRealNames(statement)
	local approved, warning = Commands.verifyStatementAsync(callerUser, statement)
	if not approved then
		return false, (warning or "Statement denied")
	end
	local callerUserId = callerUser.userId :: number
	local tasks = Commands.executeStatement(callerUserId, statement)
	return true, tasks
end

function Commands.processBatchAsync(callerUser: User, batch: Batch): (boolean, {{boolean | string}}, {Task}?)
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
		end
	end
	return atLeastOneSuccess, collectiveNotices, collectiveTasks :: {Task}
end

function Commands.verifyStatementAsync(callerUser: User, statement: Statement)--: (approved: boolean, reason: string?)
	
	if statement.isValid ~= true then
		return false, statement.errorMessage
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

	return true, nil
end

function Commands.executeStatement(callerUserId: number, statement: Statement): {Task}

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
	for qualifierKey, qualifierTable in pairs(statement.qualifiers) do
		if typeof(qualifierKey) == "Instance" and qualifierKey:IsA("Player") then
			local callerUser = User.getUserByUserId(callerUserId)
			local playerDefinedSearch: ParserTypes.PlayerSearch = Config.getSetting("PlayerDefinedSearch", callerUser)
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

	local Args = require(parser.Args)
	local tasks: {any} = {}
	local isPermModifier = statement.modifiers.perm
	local isGlobalModifier = statement.modifiers.wasGlobal
	for commandName, arguments in pairs(statement.commands) do
		
		local command = Commands.getCommand(commandName) :: Command?
		if not command or typeof(command.args) ~= "table" then
			continue
		end

		-- Its important to split commands into specific users for most cases so that the command can
		-- be easily reapplied if the player rejoins (for ones where the perm modifier is present)
		-- The one exception for this is when a global modifier is present. In this scenerio, don't save
		-- specific targetPlayers, simply use the qualifiers instead to select a general audience relevant for
		-- the particular server at time of exection.
		-- e.g. ``;permLoopKillAll`` will save each specific targetPlayer within that server and permanetly loop kill them
		-- while ``;globalLoopKillAll`` will permanently save the loop kill action and execute this within all
		-- servers repeatidly
		local addToPerm = false
		local splitIntoUsers = false
		local firstArgNameOrDetail = command.args[1]
		local firstArg = Args.get(firstArgNameOrDetail)
		local executeForEachPlayer = if firstArg then firstArg.executeForEachPlayer else false
		if isPermModifier then
			if isGlobalModifier then
				addToPerm = true
			elseif executeForEachPlayer then
				addToPerm = true
				splitIntoUsers = true
			end
		else
			splitIntoUsers = executeForEachPlayer
		end

		-- Define the properties that we'll create the task from arguments
		local args = (arguments or {}) :: ArgGroup
		local qualifiers = (statement.qualifiers or {}) :: ArgGroup
		local modifiers = (statement.modifiers or {}) :: ArgGroup
		local generateUID = require(modules.DataUtil.generateUID)
		local taskUID = statement.taskUID or generateUID(10)
		local commandNameLower = string.lower(commandName)

		-- Create task wrapper
		local function createTask(optionalTargetUserId: number?): Task?
			
			-- Setup task properties
			local properties: Properties = {
				callerUserId = callerUserId,
				targetUserId = optionalTargetUserId,
				commandName = commandName,
				commandNameLower = commandNameLower,
				args = args,
				modifiers = modifiers,
				qualifiers = qualifiers,
				isRestricted = statement.isRestricted,
				UID = taskUID,
			}

			-- Undo taks if already applied to player (or server level)
			local runningTasks = Task.getTasks(commandName, optionalTargetUserId)
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

			-- Block the command from running if a cooldown is already active
			if hasACooldown and #runningTasks > 0 then
				local activeTask = runningTasks[1]
				local endTime = activeTask.cooldownEndTime
				local additionalUserMessage = ""
				local associatedPlayer = activeTask.target
				if associatedPlayer then
					additionalUserMessage = ` on {associatedPlayer.DisplayName}' (@{associatedPlayer.Name})`
				end
				local warningNotice
				if endTime then
					local remainingTime = (math.ceil((endTime-os.clock())*100))/100
					warningNotice = `Wait {remainingTime} seconds until using '{commandName}' again{additionalUserMessage}!`
				else
					warningNotice = `Wait until '{commandName}' has finished before using again{additionalUserMessage}!`
				end
				warn(warningNotice) --!!!notice
				return nil
			end

			-- Finally all good, now create task
			local task = Task.new(properties)
			return task

		end

		-- Tasks are split into separate players (such as those with the 'Player' arg),
		-- while some do not (such as those with the 'Players' arg, or without any type
		-- of player arg at all)
		if not splitIntoUsers then
			local task = createTask()
			if task then
				table.insert(tasks, task)
			end
		else
			local targetPlayers = if firstArg then firstArg:parse(statement.qualifiers, callerUserId) else {}
			for _, plr in targetPlayers do
				local task = createTask(plr.UserId)
				if task then
					table.insert(tasks, task)
				end
			end
		end
	end

	return tasks :: {Task}
end


return Commands