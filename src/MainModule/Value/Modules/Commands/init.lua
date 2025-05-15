--!strict
-- LOCAL
local Commands = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local parser = modules.Parser
local Args = require(parser.Args)
local User = require(modules.Objects.User)
local ParserTypes = require(parser.ParserTypes)
local ParserUtility = require(parser.ParserUtility)
local commandsArray: {Command} = {}
local lowerCaseNameAndAliasCommandsDictionary: {[string]: Command} = {}
local sortedNameAndAliasLengthArray: {string} = {}
local commandsRequireUpdating = true
local commandPrefixes = {}


-- TYPES
type User = User.Class
type Batch = ParserTypes.ParsedBatch
type Statement = ParserTypes.ParsedStatement

export type Task = {
	defer: (any, any) -> (),
	hiiiiii: (any, any) -> (),
}

export type Command = {
	--[string]: any,
	name: string,
	aliases: {string},
	args: {Args.Argument},
	prefixes: {string}?,
}

export type ClientCommand = {
	--[string]: any,
	name: string,
	args: {Args.Argument},
	--run: (() -> ()),
}


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

function Commands.processStatementAsync(callerUser: User, statement: Statement)
	-- This verifies and executes the statement (if permitted)
	local callerUserId = callerUser.userId
	local callerPlayer = callerUser.player
	local Promise = main.modules.Promise
	return Commands.verifyStatement(callerUser, statement)
		:andThen(function(approved, noticeDetails)
			if callerPlayer then
				for _, detail in pairs(noticeDetails) do
					local method = main.services.MessageService[detail[1]]
					method(callerPlayer, detail[2])
				end
			end
			if approved then
				return Promise.new(function(resolve, reject)
					local sucess, jobsOrWarning = Commands.executeStatement(callerUserId, statement):await()
					if sucess then
						return resolve(true, jobsOrWarning)
					end
					reject(jobsOrWarning)
				end)
			end
			return false
		end)
end

function Commands.processBatchAsync(callerUser: User, batch: Batch)
	-- This verifies and executes the statements within the batch (if permitted)
	if true then
		print("batch =", batch)
		return
	end
	local callerUserId = callerUser.userId
	local Promise = main.modules.Promise
	return Promise.defer(function(resolve, reject)
		if type(batch) ~= "table" then
			return resolve(false, "The batch must be a table!")
		end
		local approvedPromises = {}
		for _, statement in pairs(batch) do
			if type(batch) ~= "table" then
				return resolve(false, "Statements must be a table!")
			end
			statement.message = message
			table.insert(approvedPromises, Promise.new(function(subResolve, subReject)
				local success, approved, noticeDetails = Commands.verifyStatement(callerUser, statement):await()
				if success and approved then
					subResolve()
				elseif not success then
					reject(approved)
					subReject()
				else
					subReject()
				end
			end))
		end
		local approvedAllStatements = Promise.all(approvedPromises):await()
		if not approvedAllStatements then
			return resolve(false, "Invalid permission to execute all statements")
		end
		local collectiveJobs = {}
		for _, statement in pairs(batch) do
			local sucess, jobs = Commands.executeStatement(callerUserId, statement):await()
			if sucess then
				for _, job in pairs(jobs) do
					table.insert(collectiveJobs, job)
				end
			end
		end
		resolve(true, collectiveJobs)
	end)
end

function Commands.verifyStatement(callerUser, statement)
	local approved = true
	local details = {}
	local Promise = main.modules.Promise
	local RoleService = main.services.RoleService
	local Args = main.modules.Parser.Args
	local callerUserId = callerUser.userId

	-- argItem.verifyCanUse can sometimes be asynchronous therefore we return and resolve a Promise
	local promise = Promise.defer(function(resolve, reject)
		
		if typeof(statement) ~= "table" then
			return resolve(false, {{"notice", {
				text = "Statements must be tables!",
				error = true,
			}}})
		end
		--ParserUtility.convertStatementToRealNames(statement) -- Don't do anymore
		
		local jobId = statement.jobId
		local statementCommands = statement.commands
		local modifiers = statement.modifiers
		local qualifiers = statement.qualifiers
		
		if not statementCommands then
			return resolve(false, {{"notice", {
				text = "Failed to execute command as it does not exist!",
				error = true,
			}}})
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
				return resolve(false, {{"notice", {
					text = string.format("'%s' is an invalid command name!", commandName),
					error = true,
				}}})
			end

			-- Does the caller have permission to use it
			local commandNameLower = string.lower(commandName)
			if not RoleService.verifySettings(callerUser, "commands").have(commandNameLower) then
				--!!! RE_ENABLE THIS
				--[[return resolve(false, {{"notice", {
					text = string.format("You do not have permission to use command '%s'!", commandName),
					error = true,
				}}})
				return--]]
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
	end)

	return promise:andThen(function(approved, noticeDetails)
		-- This fires off any notifications to the caller
		local callerPlayer = callerUser.player
		if callerPlayer then
			for _, detail in pairs(noticeDetails) do
				local method = main.services.MessageService[detail[1]]
				method(callerPlayer, detail[2])
			end
		end
		return approved, noticeDetails
	end)
end

function Commands.executeStatement(callerUserId, statement)

	--ParserUtility.convertStatementToRealNames(statement) -- Don't do anymore

	statement.commands = statement.commands or {}
	statement.modifiers = statement.modifiers or {}
	statement.qualifiers = statement.qualifiers or {}

	if statement.restrict == nil then
		local callerUser = main.modules.PlayerStore:getUserByUserId(callerUserId)
		if callerUser then
			statement.restrict = not main.services.RoleService.verifySettings(callerUser, "ignore.roleRestrictions").areSome(true)
		end
		if statement.restrict  == nil then
			statement.restrict = true
		end
	end
	
	-- If 'player' instance detected within qualifiers, convert to player.Name
	for qualifierKey, qualifierTable in pairs(statement.qualifiers) do
		if typeof(qualifierKey) == "Instance" and qualifierKey:IsA("Player") then
			local callerUser = main.modules.PlayerStore:getUserByUserId(callerUserId)
			local playerDefinedSearch = main.services.SettingService.getUsersPlayerSetting(callerUser, "playerIdentifier")
			local playerName = qualifierKey.Name
			if playerDefinedSearch == main.enum.PlayerSearch.UserName or playerDefinedSearch == main.enum.PlayerSearch.UserNameAndDisplayName then
				local playerIdentifier = main.services.SettingService.getUsersPlayerSetting(callerUser, "playerIdentifier")
				playerName = tostring(playerIdentifier)..playerName
			end
			statement.qualifiers[qualifierKey] = nil
			statement.qualifiers[playerName] = qualifierTable
		end
	end

	-- This enables the preview modifier if command.autoPreview is true
	-- or bypasses the preview modifier entirely if the request is from the client
	if statement.fromClient then
		statement.modifiers.preview = nil
	else
		for commandName, arguments in pairs(statement.commands) do
			local command = Commands.getCommand(commandName)
			if command.autoPreview then
				statement.modifiers.preview = statement.modifiers.preview or true
				break
			end
		end
	end

	-- This handles any present modifiers
	-- If the modifier preAction value returns false then cancel the execution
	local Promise = main.modules.Promise
	local Modifiers = main.modules.Parser.Modifiers
	for modifierName, _ in pairs(statement.modifiers) do
		local modifierItem = Modifiers.get(modifierName)
		if modifierItem then
			local continueExecution = modifierItem.preAction(callerUserId, statement)
			if not continueExecution then
				return Promise.new(function(resolve)
					resolve({})
				end)
			end
		end
	end

	local Args = main.modules.Parser.Args
	local promises = {}
	local jobs = {}
	local isPermModifier = statement.modifiers.perm
	local isGlobalModifier = statement.modifiers.wasGlobal
	for commandName, arguments in pairs(statement.commands) do
		
		local command = Commands.getCommand(commandName)
		local firstArgName = command.args[1] or ""
		local executeForEachPlayerFirstArg = Args.executeForEachPlayerArgsDictionary[string.lower(firstArgName)]
		local JobService = main.services.JobService
		local properties = JobService.generateRecord()
		properties.callerUserId = callerUserId
		properties.commandName = commandName
		properties.args = arguments or properties.args
		properties.modifiers = statement.modifiers
		properties.restrict = statement.restrict
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
		if not splitIntoUsers then
			properties.qualifiers = statement.qualifiers or properties.qualifiers
			local job = main.services.JobService.createJob(addToPerm, properties)
			if job then
				table.insert(jobs, job)
			end
		else
			table.insert(promises, Promise.defer(function(resolve)
				local targetPlayers = Args.get("player"):parse(statement.qualifiers, callerUserId)
				for _, plr in pairs(targetPlayers) do
					local newProperties = main.modules.TableUtil.copy(properties)
					newProperties.playerUserId = plr.UserId
					local job = main.services.JobService.createJob(addToPerm, newProperties)
					if job then
						table.insert(jobs, job)
					end
				end
				resolve()
			end):catch(warn))
		end
	end
	return Promise.all(promises)
		:andThen(function()
			return jobs
		end)
end


return Commands