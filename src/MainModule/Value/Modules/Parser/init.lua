--!strict
-- CONFIG
local MAX_CHARACTERS_PER_MESSAGE = 1000 -- The maximum number of characters for a message before it's trimmed to avoid abuse (e.g. if the user pastes a 10,000+ character message)


-- LOCAL
local Parser = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local ParserTypes = require(script.ParserTypes)


-- FUNCTIONS
function Parser.parse(message: string, optionalUser: any?): ParserTypes.ParsedBatch
	-- This is ONLY useable on the SERVER
	local services = modules.Parent.Services
	local Commands = require(services.Commands)
	local Config = require(modules.Parent.Services.Config)
	local Modifiers = require(modules.Parser.Modifiers)
	local User = require(modules.Objects.User)

	local Algorithm = require(script.Algorithm)
	local forEveryCommand = require(script.Parent.CommandUtil.forEveryCommand)
	local ParsedData = require(script.ParsedData)
	local allParsedDatas = {}

	-- Ensure message is a string
	if typeof(message) ~= "string" then
		message = ""
	end

	-- Trim message to avoid abuse
	if #message > MAX_CHARACTERS_PER_MESSAGE then
		message = string.sub(message, 1, MAX_CHARACTERS_PER_MESSAGE)
	end
	
	-- player.Chatted processes ">" as "&gt;" and "<" as "&lt;"
	-- e.g., if someone chatted ">kill me", it produces "&gt;kill me"
	-- This reverts this behaviour so that these characters can be used as prefixes
	message = string.gsub(message, "&gt;", ">")
	message = string.gsub(message, "&lt;", "<")

	-- Account for 'silent' commands by supporting '/e' (e.g. "/e ;fly me")
	if string.sub(message,1,3) == "/e " then
		message = string.sub(message,4)
	end

	-- Retrieve the first character of the message
	-- If blank, ignore
	local firstPos = string.find(message, "%S") :: number
	local firstChar = if firstPos then string.sub(message, firstPos, firstPos) else nil
	if firstChar == nil then
		return {}
	end

	-- ... otherwise ensure that the first character is a valid prefix.
	-- If not valid, ignore parsing entirely and save resources
	local secondChar = string.sub(message, firstPos+1, firstPos+1)
	local commandPrefixes = Commands.getCommandPrefixes()
	local validPrefixesForThisUser = {}
	local defaultGamePrefix = Config.getSetting("Prefix")
	local usersPrefix = Config.getSetting("Prefix", optionalUser)
	local isCommandSpecificPrefix = firstChar ~= defaultGamePrefix and firstChar ~= usersPrefix
	validPrefixesForThisUser[defaultGamePrefix] = true
	validPrefixesForThisUser[usersPrefix] = true
	for prefix, _ in commandPrefixes do
		validPrefixesForThisUser[prefix] = true
	end
	if not validPrefixesForThisUser[firstChar] then
		return {}
	end

	-- This is the main parser handler which breaks down the message into
	-- readable statements of information
	local givenPrefix = firstChar
	local statements = Algorithm.getCommandStatementsFromBatch(message, givenPrefix)
	for _, commandStatement in statements do
		
		-- Step 1
		local parsedData = ParsedData.generateEmptyParsedData(givenPrefix) :: any
		parsedData.commandStatement = commandStatement

		-- Step 2
		ParsedData.parseCommandStatement(parsedData)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData :: any)
			continue
		end

		-- Step 3
		ParsedData.parseCommandDescriptionAndSetFlags(parsedData :: any, optionalUser)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData)
			continue
		end

		-- Step 4
		ParsedData.parseQualifierDescription(parsedData :: any)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData)
			continue
		end

		-- Step 5
		parsedData = parsedData :: any
		ParsedData.parseExtraArgumentDescription(parsedData, allParsedDatas, message)
		table.insert(allParsedDatas, parsedData)
		if parsedData.hasTextArgument then
			break
		end
	end

	-- Step 6
	local parsedBatch = ParsedData.generateOrganizedParsedData(allParsedDatas)
	
	-- Step 7, final command configuration
	for _, statement in parsedBatch do
		local modifiers = statement.modifiers
		local namesToChange = {}
		local statementCommands = statement.commands
		for commandName, _ in statementCommands do

			-- Ensure commands within parsedData are executable with the given prefix
			-- If not, convert into error statement
			-- This also handles the logic for override commands
			local originalCommandName = commandName
			local command, isOverride = Commands.getCommand(commandName, givenPrefix)
			if command == nil then
				ParsedData.invalidateStatement(statement, `Command '{commandName}' does not exist`)
				continue
			end
			local isValidWithPrefix = true
			local silencedCommand = command :: any
			local prefixes = silencedCommand.prefixes
			if isCommandSpecificPrefix and not isOverride then
				isValidWithPrefix = false
				if prefixes then
					for _, prefix in (prefixes :: any) do
						if prefix == firstChar then
							isValidWithPrefix = true
							break
						end
					end
				end
			end
			local userAndDefaultPrefixMatchButIsOverride = firstChar == secondChar -- We do this because prefix data is eliminated when parsed
			if isOverride or not isValidWithPrefix or userAndDefaultPrefixMatchButIsOverride then
				commandName = givenPrefix..commandName
				if not isValidWithPrefix then
					local overrideCommand = Commands.getCommand(commandName)
					if overrideCommand == nil then
						ParsedData.invalidateStatement(statement, `Override command '{commandName}' does not exist`)
						continue
					end
					isValidWithPrefix = true
				end
				namesToChange[originalCommandName] = commandName
			end
			if isValidWithPrefix == false then
				ParsedData.invalidateStatement(statement, `Command '{commandName}' is not valid with prefix '{firstChar}`)
				continue
			end

			-- If commandName is an undoAlias, ensure that the command has an undo modifier
			local commandNameLower = commandName:lower()
			local undoAliases = command.undoAliases
			if typeof(undoAliases) == "table" and not modifiers.undo and not modifiers.un then
				for _, alias in undoAliases do
					if typeof(alias) == "string" and alias:lower() == commandNameLower then
						modifiers.undo = {}
					end
				end
			end

		end

		-- We replace override names at the end to guarantee the entire dictionary is first checked
		for originalName, newName in namesToChange do
			statementCommands[newName] = statementCommands[originalName]
			statementCommands[originalName] = nil
		end
	end

	-- Now return
	return parsedBatch
end

function Parser.addCapsule(baseString: string, capsuleStringOrStrings: string | {string})
	-- This is useable on both server and client
	-- Wraps the capsule string within capsule brackets (), and if more than one item, also
	-- separates them with commas (or whatever the Collective is set to)
	local ParserSettings = require(modules.Parser.ParserSettings)
	local collective = ParserSettings.Collective
	local capsuleString = capsuleStringOrStrings
	if typeof(capsuleStringOrStrings) == "table" then
		capsuleString = table.concat(capsuleStringOrStrings, collective)
	end
	if capsuleString == "" or capsuleString == " " then
		return baseString
	end
	return `{baseString}({capsuleString})`
end

function Parser.unparse(commandName: string, modifiers: {string}, ...: any): string
	-- This is useable on both server and client
	-- This accepts a commandName, modifierStringArray, and arg results of that command
	-- which is then converted into a stringified version of the command, e.g:
	-- ";globalPaint me,role(admin) 255,0,0"

	-- First we make sure the command is an actual command otherwise the args can't be unparsed
	local getCommand = require(modules.CommandUtil.getCommand)
	local command = getCommand(commandName)
	if not command then
		return ";unknownResult"
	end

	-- Now we organise each arg and prepare it to be parsed
	-- It's important we determine how many endlessArgs there are because
	-- this will require modifying their result if > 2
	local commandArgs = command.args
	local Args = require(modules.Parser.Args)
	local valuesToUnParse = {...}
	local parsedArray: {string} = {}
	local function forEveryArg(callback)
		for i, argNameOrInfo in commandArgs do
			local argInfo = argNameOrInfo
			if typeof(argInfo) ~= "table" then
				argInfo = Args.get(argNameOrInfo)
			end
			argInfo = argInfo :: any
			callback(argInfo, i)
		end
	end
	local totalEndlessArgs = 0
	forEveryArg(function(argInfo, i)
		if argInfo.endlessArg then
			totalEndlessArgs = totalEndlessArgs + 1
		end
	end)
	
	-- Now we unparse each arg with its given value (to become stringified)
	local ParserSettings = require(modules.Parser.ParserSettings)
	local endlessArgPattern = ParserSettings.EndlessArgPattern
	local totalArgs = #commandArgs
	forEveryArg(function(argInfo, i)
		local stringValue = ""
		local unparse = argInfo and argInfo.unparse	
		if unparse then
			local newStringValue = argInfo:unparse(valuesToUnParse[i])
			if typeof(newStringValue) == "string" then
				if argInfo.endlessArg and totalEndlessArgs > 1 and i ~= totalArgs then
					newStringValue = newStringValue..endlessArgPattern
				end
				stringValue = newStringValue
			end
		end
		table.insert(parsedArray, stringValue :: string)
	end)

	-- Next, we want to build the command string, which includes the command name
	-- and any modifiers (like global, loop, etc). For this, we capitalize each
	-- item *except* for the first item, which is lowercased, to make it easy
	-- and presentable to read
	local commandStartArray: {string} = {}
	local capitalize = require(modules.DataUtil.capitalize)
	if modifiers then
		for _, modifierAndCapsule in modifiers do
			local capitalizedModifier = capitalize(modifierAndCapsule)
			table.insert(commandStartArray, capitalizedModifier)
		end
	end
	local capitalizedCommandName = capitalize(commandName)
	table.insert(commandStartArray, capitalizedCommandName)
	local firstItemLower = (commandStartArray[1] or ""):lower()
	commandStartArray[1] = firstItemLower

	-- Finally, we combine it all together and add that prefix at the start
	local spaceSeparator = ParserSettings.SpaceSeparator
	local unparsedArgsSpacedOut = table.concat(parsedArray, spaceSeparator)
	local commandStart = table.concat(commandStartArray, "")
	local getYouSetting = require(modules.CommandUtil.getYouSetting)
	local prefix = getYouSetting("Prefix") or ""
	local unparsedString = `{prefix}{commandStart}{spaceSeparator}{unparsedArgsSpacedOut}`
	return unparsedString
end


return Parser