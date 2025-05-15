--!strict
-- LOCAL
local Parser = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Commands = require(modules.Commands)
local User = require(modules.Objects.User)
local Config = require(modules.Config)
local ParserTypes = require(script.ParserTypes)


-- FUNCTIONS
function Parser.parseMessage(message: string, optionalUser: User.Class?): ParserTypes.ParsedBatch
	
	local Algorithm = require(script.Algorithm)
	local ParsedData = require(script.ParsedData)
	local allParsedDatas = {}
	
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
	local firstChar = string.match(message, "%S")
	if firstChar == nil then
		return {}
	end

	-- ... otherwise ensure that the first character is a valid prefix.
	-- If not valid, ignore parsing entirely and save resources
	local commandPrefixes = Commands.getCommandPrefixes()
	local validPrefixesForThisUser = {}
	local defaultGamePrefix = Config.getSetting("Prefix")
	local usersPrefix = Config.getSetting("Prefix", optionalUser)
	local isCommandSpecificPrefix = firstChar ~= defaultGamePrefix and firstChar ~= usersPrefix
	validPrefixesForThisUser[defaultGamePrefix] = true
	validPrefixesForThisUser[usersPrefix] = true
	for prefix, _ in pairs(commandPrefixes) do
		validPrefixesForThisUser[prefix] = true
	end
	if not validPrefixesForThisUser[firstChar] then
		return {}
	end

	-- This is the main parser handler which breaks down the message into
	-- readable statements of information
	local statements = Algorithm.getCommandStatementsFromBatch(message, firstChar)
	for _, commandStatement in pairs(statements) do
		
		-- Step 1
		local parsedData = ParsedData.generateEmptyParsedData() :: any
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
		ParsedData.parseExtraArgumentDescription(parsedData :: any, allParsedDatas, message)
		table.insert(allParsedDatas, parsedData :: any)
		if parsedData.hasTextArgument then
			break
		end
	end

	-- Step 6
	local parsedBatch = ParsedData.generateOrganizedParsedData(allParsedDatas)

	-- Ensure commands within parsedData are executable with the given prefix
	-- If not, convert into error statement
	if isCommandSpecificPrefix then
		for _, statement in pairs(parsedBatch) do
			for commandName, _ in statement.commands do
				local command = Commands.getCommand(commandName)
				if command == nil then
					continue
				end
				local prefixes = command.prefixes
				local isValid = false
				if prefixes then
					for _, prefix in pairs(prefixes :: any) do
						if prefix == firstChar then
							isValid = true
							break
						end
					end
				end
				if isValid == false then
					statement.isValid = false
					statement.errorMessage = `Command '{commandName}' not valid with prefix '{firstChar}`
				end
			end
		end
	end

	-- Now return
	return parsedBatch
end


function Parser.stringify(statement)

end


return Parser