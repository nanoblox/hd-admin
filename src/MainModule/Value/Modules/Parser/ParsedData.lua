--!nocheck
local ParsedData = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Commands = require(services.Commands)
local ParserTypes = require(modules.Parser.ParserTypes)
local Args = require(modules.Parser.Args)
local Config = require(modules.Config)


-- TYPES
type QualifierRequired = ParserTypes.QualifierRequired
type PlayerSearch = ParserTypes.PlayerSearch
type ParserRejection = ParserTypes.ParserRejection
type ParsedStatement = ParserTypes.ParsedStatement
type ParsedBatch = ParserTypes.ParsedBatch


-- FUNCTIONS
function ParsedData.generateEmptyParsedData(givenPrefix: string?)
	return {
		givenPrefix = givenPrefix,
		commandStatement = nil,

		commandDescription = nil,
		qualifierDescription = nil,
		extraArgumentDescription = nil,

		commandCaptures = {},
		modifierCaptures = {},
		qualifierCaptures = {},
		prematureQualifierParsing = false,
		unrecognizedQualifiers = {},

		commandDescriptionResdiue = nil,

		requiresQualifier = false,
		hasEndlessArgument = false,

		isValid = true,
		parserRejection = nil,
	}
end

function ParsedData.requiresQualifier(commandName, givenPrefix): ParserTypes.QualifierRequired
	local command = Commands.getCommand(commandName, givenPrefix)
	if not command then
		return "Never"
	end
	local commandArgs = command.args
	if #commandArgs == 0 then
		return "Never"
	end
	local firstArgNameOrDetail = commandArgs[1]
	local firstArg = Args.get(firstArgNameOrDetail)
	if firstArg == nil or firstArg.playerArg ~= true then
		return "Never"
	else
		if firstArg.hidden ~= true then
			return "Always"
		else
			return "Sometimes"
		end
	end
end

function ParsedData.parsedDataSetRequiresQualifierFlag(parsedData, optionalUser)
	
	local parsedDataRequiresQualifier: QualifierRequired = "Sometimes"
	local givenPrefix = parsedData.givenPrefix
	for _, capture in parsedData.commandCaptures do
		for commandName, _ in capture do
			local commandRequiresQualifier = ParsedData.requiresQualifier(commandName, givenPrefix)
			if commandRequiresQualifier == "Always" then
				parsedDataRequiresQualifier = "Always"
				break
			elseif commandRequiresQualifier == "Never" then
				parsedDataRequiresQualifier = "Never"
			end
		end
	end

	if parsedDataRequiresQualifier ~= "Sometimes" then
		parsedData.requiresQualifier = (parsedDataRequiresQualifier == "Always")
	else
		parsedData.requiresQualifier = true
		ParsedData.parseQualifierDescription(parsedData)
		parsedData.prematureQualifierParsing = true
		local areAllQualifiersRecognized = #parsedData.qualifierCaptures ~= #parsedData.unrecognizedQualifiers

		if areAllQualifiersRecognized then
			parsedData.requiresQualifier = true
		else
			local utilityModule = require(modules.Parser.ParserUtility)
			local players = game:GetService("Players"):GetPlayers()
			local userNames = {}

			for _, player in players do
				table.insert(userNames, player.Name:lower())
			end
			
			local playerIdentifier = Config.getSetting("PlayerIdentifier", optionalUser)
			local playerDefinedSearch: PlayerSearch = Config.getSetting("PlayerDefinedSearch", optionalUser)
			local playerUndefinedSearch: PlayerSearch = Config.getSetting("PlayerUndefinedSearch", optionalUser)

			for _, qualifier in parsedData.unrecognizedQualifiers do
				local qualifierHasPlayerIdentifier = (qualifier:sub(1, 1) == playerIdentifier)
				local qualifierWithoutIdentifier = utilityModule.ternary(
					qualifierHasPlayerIdentifier,
					qualifier:sub(2, #qualifier),
					qualifier
				)

				local isUserNameSearch = utilityModule.ternary(
					qualifierHasPlayerIdentifier,
					playerDefinedSearch == "UserName",
					playerUndefinedSearch == "UserName"
				)
				local isUserNameAndDisplayNameSearch = utilityModule.ternary(
					qualifierHasPlayerIdentifier,
					playerDefinedSearch == "UserNameAndDisplayName",
					playerUndefinedSearch == "UserNameAndDisplayName"
				)

				if isUserNameSearch or isUserNameAndDisplayNameSearch then
					if table.find(userNames, qualifierWithoutIdentifier:lower()) then
						parsedData.requiresQualifier = true
						return
					end
				end
			end

			parsedData.requiresQualifier = false
			parsedData.qualifierCaptures = {}
		end
	end
end

function ParsedData.hasEndlessArgument(commandName, givenPrefix)
	local command = Commands.getCommand(commandName, givenPrefix)
	if not command then
		return false
	end
	local commandArgs = command.args
	if #commandArgs == 0 then
		return false
	end
	local lastArgNameOrDetail = commandArgs[#commandArgs]
	local lastArg = Args.get(lastArgNameOrDetail) :: any
	local bool = if lastArg and lastArg.endlessArg == true then true else false
	return bool
end

function ParsedData.parsedDataSetHasEndlessArgumentFlag(parsedData)
	local givenPrefix = parsedData.givenPrefix
	for _, capture in parsedData.commandCaptures do
		for commandName, _ in capture do
			if ParsedData.hasEndlessArgument(commandName, givenPrefix) then
				parsedData.hasEndlessArgument = true
				return
			end
		end
	end
	parsedData.hasEndlessArgument = false
end

function ParsedData.parsedDataUpdateIsValidFlag(parsedData, parserRejection: ParserRejection)
	if not parsedData.isValid then
		return
	end
	local utilityModule = require(modules.Parser.ParserUtility)
	
	if parserRejection == "MissingCommandDescription" then
		parsedData.errorMessage = "Invalid command name(s)"
		if parsedData.commandDescription == "" then
			parsedData.isValid = false
		end
	elseif parserRejection == "UnbalancedCapsulesInCommandDescription" then
		if utilityModule.getCapsuleRanges(parsedData.commandDescription) == nil then
			parsedData.isValid = false
		end
	elseif parserRejection == "UnbalancedCapsulesInQualifierDescription" then
		if utilityModule.getCapsuleRanges(parsedData.qualifierDescription) == nil then
			parsedData.isValid = false
		end
	elseif parserRejection == "MissingCommands" then
		if #parsedData.commandCaptures == 0 then
			parsedData.isValid = false
		end
	elseif parserRejection == "MalformedCommandDescription" then
		if parsedData.commandDescriptionResidue ~= "" then
			parsedData.isValid = false
		end
	end

	if not parsedData.isValid then
		parsedData.parserRejection = parserRejection
	end
end

function ParsedData.invalidateStatement(statement: any, errorMessage: string)
	statement.isValid = false
	statement.errorMessage = errorMessage
end

function ParsedData.generateOrganizedParsedData(allParsedData)
	local parsedBatch: ParsedBatch = {}
	for _, parsedData in allParsedData do

		local parsedStatement: ParserTypes.ParsedStatement = {
			isValid = true,
			isConverted = false,
			isFromClient = false,
			commands = {},
			modifiers = {},
			qualifiers = {},
			errorMessage = nil,
		}

		if parsedData.isValid then
			for _, capture in parsedData.commandCaptures do
				for command, arguments in capture do
					parsedStatement.commands[command] = arguments
				end
			end
			for _, capture in parsedData.modifierCaptures do
				for modifier, arguments in capture do
					parsedStatement.modifiers[modifier] = arguments
				end
			end
			for _, capture in parsedData.qualifierCaptures do
				for qualifier, arguments in capture do
					parsedStatement.qualifiers[qualifier] = arguments
				end
			end

		else
			local errorMessage = parsedData.errorMessage or parsedData.parserRejection
			ParsedData.invalidateStatement(parsedStatement, errorMessage)
		end

		table.insert(parsedBatch, parsedStatement)
	end
	return parsedBatch
end

function ParsedData.parseCommandStatement(parsedData)
	local algorithmModule = require(modules.Parser.Algorithm)
	
	local descriptions = algorithmModule.getDescriptionsFromCommandStatement(parsedData.commandStatement)
	
	parsedData.commandDescription = descriptions[1]
	parsedData.qualifierDescription = descriptions[2]
	parsedData.extraArgumentDescription = descriptions[3]

	ParsedData.parsedDataUpdateIsValidFlag(parsedData, "MissingCommandDescription")
	ParsedData.parsedDataUpdateIsValidFlag(parsedData, "UnbalancedCapsulesInCommandDescription")
	ParsedData.parsedDataUpdateIsValidFlag(parsedData, "UnbalancedCapsulesInQualifierDescription")
end

function ParsedData.parseCommandDescription(parsedData)
	local algorithmModule = require(modules.Parser.Algorithm)

	local capturesAndResidue = algorithmModule.parseCommandDescription(parsedData.commandDescription)

	parsedData.commandCaptures = capturesAndResidue[1]
	parsedData.modifierCaptures = capturesAndResidue[2]
	parsedData.commandDescriptionResidue = capturesAndResidue[3]

	ParsedData.parsedDataUpdateIsValidFlag(parsedData, "MissingCommands")
	ParsedData.parsedDataUpdateIsValidFlag(parsedData, "MalformedCommandDescription")
end

function ParsedData.parseCommandDescriptionAndSetFlags(parsedData, optionalUser)
	ParsedData.parseCommandDescription(parsedData)
	if parsedData.isValid then
		ParsedData.parsedDataSetRequiresQualifierFlag(parsedData, optionalUser)
		ParsedData.parsedDataSetHasEndlessArgumentFlag(parsedData)
	end
end

function ParsedData.parseQualifierDescription(parsedData)
	if not parsedData.requiresQualifier then
		return
	end
	if parsedData.prematureQualifierParsing then
		return
	end

	local algorithmModule = require(modules.Parser.Algorithm)

	local qualifierCapturesAndUnrecognizedQualifiers =
		algorithmModule.parseQualifierDescription(parsedData.qualifierDescription)

	parsedData.qualifierCaptures = qualifierCapturesAndUnrecognizedQualifiers[1]
	parsedData.unrecognizedQualifiers = qualifierCapturesAndUnrecognizedQualifiers[2]
end

--[[



]]
function ParsedData.parseExtraArgumentDescription(parsedData, allParsedDatas, originalMessage)
	local givenPrefix = parsedData.givenPrefix
	if not parsedData.hasEndlessArgument then
		if not parsedData.requiresQualifier then
			table.insert(parsedData.extraArgumentDescription, parsedData.qualifierDescription)
			parsedData.qualifierDescription = nil
		end

		for _, extraArgument in parsedData.extraArgumentDescription do
			for _, capture in parsedData.commandCaptures do
				for _, arguments in capture do
					table.insert(arguments, extraArgument)
				end
			end
		end
	else
		local foundIndex = 0

		for counter = 1, #allParsedDatas + 1 do
			foundIndex = select(2, string.find(originalMessage, ";", foundIndex + 1))
		end

		foundIndex = select(2, string.find(originalMessage, parsedData.commandDescription, foundIndex + 1, true)) + 2

		if parsedData.requiresQualifier then
			foundIndex = select(2, string.find(originalMessage, parsedData.qualifierDescription, foundIndex, true)) + 2
		end

		local extraArgumentsBeforeText = math.huge
		for _, capture in parsedData.commandCaptures do
			for commandName, arguments in capture do
				local command = Commands.getCommand(commandName, givenPrefix)
				local commandArgumentNames = command.args

				local firstArgumentNameOrDetail = commandArgumentNames[1]
				local firstArgument = Args.get(firstArgumentNameOrDetail)
				local isPlayerArgument = firstArgument.playerArg == true

				local lastArgumentNameOrDetail = commandArgumentNames[#commandArgumentNames]
				local lastArgument = Args.get(lastArgumentNameOrDetail)
				local hasEndlessArgument = lastArgument.endlessArg == true

				local commandArguments = #commandArgumentNames
				local capsuleArguments = #arguments

				local commandArgumentsInExtraArguments = commandArguments
					- capsuleArguments
					- (isPlayerArgument and 1 or 0)

				if hasEndlessArgument then
					extraArgumentsBeforeText = math.min(extraArgumentsBeforeText, commandArgumentsInExtraArguments - 1)
				end
			end
		end
		if extraArgumentsBeforeText == math.huge then
			extraArgumentsBeforeText = 0
		end

		for counter = 1, extraArgumentsBeforeText do
			foundIndex = select(2, string.find(originalMessage, " ", foundIndex + 1))
			if foundIndex then
				foundIndex = foundIndex + 1
			else
				break
			end
		end

		local extraArgument = foundIndex and string.sub(originalMessage, foundIndex :: any) or nil
		for _, capture in parsedData.commandCaptures do
			for _, arguments in capture do
				for counter = 1, extraArgumentsBeforeText do
					table.insert(arguments, parsedData.extraArgumentDescription[counter])
				end
				table.insert(arguments, extraArgument)
			end
		end
	end
end


return ParsedData