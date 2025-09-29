--!strict
-- CONFIG
local MAX_CHARACTERS_PER_MESSAGE = 1000 -- The maximum number of characters for a message before it's trimmed to avoid abuse (e.g. if the user pastes a 10,000+ character message)


-- LOCAL
local Parser = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Commands = require(services.Commands)
local User = require(modules.Objects.User)
local Config = require(modules.Config)
local ParserTypes = require(script.ParserTypes)


-- FUNCTIONS
function Parser.parseMessage(message: string, optionalUser: User.Class?): ParserTypes.ParsedBatch
	
	local Algorithm = require(script.Algorithm)
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


function Parser.stringify(statement)

end


return Parser