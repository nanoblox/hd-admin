--!strict
-- LOCAL
local Commands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local parser = modules.Parser
local User = require(modules.Objects.User)
local ParserTypes = require(parser.ParserTypes)
local Promise = require(modules.Objects.Promise)
local Config = require(modules.Config)
local Task = require(modules.Objects.Task)
local commandsArray: {Command} = {}
local lowerCaseNameAndAliasCommandsDictionary: {[string]: Command} = {}
local sortedNameAndAliasLengthArray: {string} = {}
local commandsRequireUpdating = true
local commandPrefixes = {}


-- TYPES
type User = User.Class
type Batch = ParserTypes.ParsedBatch
type Statement = ParserTypes.ParsedStatement
type ArgGroup = {[string]: {string}}
export type Command = Task.Command -- Moved under 'Task' to prevent cyclical warning
export type ClientCommand = Task.ClientCommand -- Moved under 'Task' to prevent cyclical warning
export type TriStateSetting = Task.TriStateSetting
export type Properties = Task.Properties


-- FUNCTIONS
function Commands.updateCommands()
	if not commandsRequireUpdating then
		return false
	end
	commandsRequireUpdating = false
	commandsArray = {}
	lowerCaseNameAndAliasCommandsDictionary = {}
	sortedNameAndAliasLengthArray = {}
	for _, container in pairs(script:GetChildren()) do
		if not container:IsA("ModuleScript") then
			continue
		end
		local commandsInside = require(container) :: {Command}
		if typeof(commandsInside) ~= "table" then
			continue
		end
		for _, command in pairs(commandsInside) do
			local prefixes = command.prefixes
			if prefixes then
				for _, prefix in pairs(prefixes) do
					if typeof(prefix) == "string" then
						commandPrefixes[prefix] = true
					end
				end
			end
			table.insert(commandsArray, command)
			local function registerNameOrAlias(nameOrAlias: string)
				if typeof(nameOrAlias) ~= "string" then
					return false
				end
				local nameOrAliasLower = nameOrAlias:lower()
				lowerCaseNameAndAliasCommandsDictionary[nameOrAliasLower] = command
				table.insert(sortedNameAndAliasLengthArray, nameOrAliasLower)
				return true
			end
			registerNameOrAlias(command.name)
			if typeof(command.aliases) == "table" then
				for _, alias in pairs(command.aliases) do
					registerNameOrAlias(alias)
				end
			end
		end
	end
	table.sort(sortedNameAndAliasLengthArray, function(a: string, b: string): boolean
		return #a > #b
	end)
	return true
end

function Commands.getCommand(nameOrAlias: string): Command?
	Commands.updateCommands()
	local lowerNameOrAlias = nameOrAlias:lower()
	local command = lowerCaseNameAndAliasCommandsDictionary[lowerNameOrAlias] :: Command?
	return command
end

function Commands.getCommandsArray()
	Commands.updateCommands()
	return commandsArray
end

function Commands.getLowerCaseNameAndAliasToCommandDictionary()
	Commands.updateCommands()
	return lowerCaseNameAndAliasCommandsDictionary
end

function Commands.getSortedNameAndAliasLengthArray()
	Commands.updateCommands()
	return sortedNameAndAliasLengthArray
end

function Commands.getCommandPrefixes()
	Commands.updateCommands()
	return commandPrefixes
end

function Commands.processStatementAsync(callerUser: User, statement: Statement): (boolean, string | {any})
	-- This verifies and executes the statement (if permitted)
	local approved, reason = Commands.verifyStatementAsync(callerUser, statement)
	if not approved then
		return false, reason or "Statement denied"
	end
	local callerUserId = callerUser.userId :: number
	local tasks = Commands.executeStatement(callerUserId, statement)
	return true, tasks
end

function Commands.processBatchAsync(callerUser: User, batch: Batch): (boolean, {{boolean | string}}, {any}?)
	-- This verifies and executes the statements within the batch (if permitted)
	if type(batch) ~= "table" then
		return false, {{false, "The batch must be a table!"}}, nil
	end
	local approvedPromises = {}
	local reasons = {}
	for _, statement in pairs(batch) do
		if type(statement) ~= "table" then
			return false, {{false, "Statements must be a table!"}}, nil
		end

		table.insert(approvedPromises, Promise.new(function(resolve, reject)
			local approved, reason = Commands.verifyStatementAsync(callerUser, statement)
			if approved == false and typeof(reason) == "string" then
				table.insert(reasons, {approved, reason})
			end
			if approved then
				resolve(reason)
			else
				reject(reason)
			end
		end::any))

	end
	local promises = Promise.all(approvedPromises) :: any
	local approvedAllStatements = promises:await()
	if not approvedAllStatements then
		return false, reasons, nil
	end
	local collectiveTasks = {}
	local callerUserId = callerUser.userId :: number
	local success = false
	for _, statement in pairs(batch) do
		local tasks = Commands.executeStatement(callerUserId, statement)
		if typeof(tasks) == "table" then
			for _, task in pairs(tasks :: any) do
				success = true
				table.insert(collectiveTasks, task)
			end
		end
	end
	return success, reasons, collectiveTasks
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
		for _, argNameOrAlias in pairs(command.args) do
			local argItem = Args.get(argNameOrAlias)
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

function Commands.executeStatement(callerUserId: number, statement: Statement): {any}

	print("Task creation (1)")
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
	--ParserUtility.convertStatementToRealNames(statement) -- Don't do anymore
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

	print("Task creation (2)")
	local Args = require(parser.Args)
	local promises = {}
	local tasks = {}
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
		local firstArgName = command.args[1] or ""
		local lowerFirstArgName = string.lower(firstArgName)
		local executeForEachPlayerFirstArg = Args.getExecuteForEachPlayerArgsDictionary(lowerFirstArgName)
		if isPermModifier then
			if isGlobalModifier then
				addToPerm = true
			elseif executeForEachPlayerFirstArg then
				addToPerm = true
				splitIntoUsers = true
			end
		else
			splitIntoUsers = executeForEachPlayerFirstArg
		end

		-- Define the properties that we'll create the task from arguments
		local args = (arguments or {}) :: ArgGroup
		local qualifiers = (statement.qualifiers or {}) :: ArgGroup
		local modifiers = (statement.modifiers or {}) :: ArgGroup
		local generateUID = require(modules.Utility.DataUtil.generateUID)
		local taskUID = statement.taskUID or generateUID(10)
		local commandNameLower = string.lower(commandName)

		-- Create task wrapper
		local function createTask(optionalPlayerUserId: number?): Task.Class?
			
			-- Setup task properties
			local properties: Properties = {
				callerUserId = callerUserId,
				playerUserId = optionalPlayerUserId,
				commandName = commandName,
				commandNameLower = commandNameLower,
				args = args,
				modifiers = modifiers,
				qualifiers = qualifiers,
				isRestricted = statement.isRestricted,
				UID = taskUID,
			}

			-- Revoke commands if already applied to player (if command requires)
			local runningTasks = Task._getters.getTasksWithCommandNameAndOptionalPlayerUserId(commandName, optionalPlayerUserId)
			if command.revokeRepeats == true then
				for _, task in pairs(runningTasks) do
					task._properties.cooldown = 0
					task:destroy()
				end
				return nil
			end
			
			-- If the command has a cooldown, check if it can be used again
			local preventRepeatsTri = command.preventRepeats :: TriStateSetting?
			local preventRepeats = true
			if preventRepeatsTri == nil or preventRepeatsTri == "Default" then
				preventRepeats = Config.getSetting("PreventRepeats")
			elseif preventRepeatsTri == "False" then
				preventRepeats = false
			end
			if preventRepeats and #runningTasks > 0 then
				local firstRunningTask = runningTasks[1]
				local firstRunningProps = firstRunningTask._properties
				local taskCooldownEndTime = firstRunningProps.cooldownEndTime
				local additionalUserMessage = ""
				local associatedPlayer = firstRunningProps.player
				if associatedPlayer then
					additionalUserMessage = (" on '%s' (@%s)"):format(associatedPlayer.DisplayName, associatedPlayer.Name)
				end
				if taskCooldownEndTime then
					local remainingTime = (math.ceil((taskCooldownEndTime-os.clock())*100))/100
					warn((`Wait {remainingTime} seconds until command '{commandName}' has cooldown before using again{additionalUserMessage}!`)) --!!!notice
					return nil
				end
				warn((`Wait until command '{commandName}' has finished before using again{additionalUserMessage}!`)) --!!!notice
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
			table.insert(promises, Promise.new(function(resolve)
				local playerArg = Args.get("Player")
				local targetPlayers = if playerArg then playerArg:parse(statement.qualifiers, callerUserId) else {}
				for _, plr in pairs(targetPlayers) do
					local task = createTask()
					if task then
						table.insert(tasks, task)
					end
				end
				resolve()
			end::any))
		end
	end

	-- We now wait until every task has been registered
	local allPromise = Promise.all(promises) :: any
	allPromise:await()

	print("Task creation (3)")
	return tasks
end


return Commands