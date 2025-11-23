--!nocheck
local EncodingService = game:GetService("EncodingService")
local ParsedData = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local Commands = require(services.Commands)
local ParserTypes = require(modules.Parser.ParserTypes)
local Args = require(modules.Parser.Args)
local Config = require(modules.Parent.Services.Config)
local ConfigSettings = require(modules.Parent.Services.Config.Settings)


-- TYPES
type QualifierRequired = ParserTypes.QualifierRequired
type PlayerSearch = ConfigSettings.PlayerSearch
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

	local function enableRequiresQualifier(ignoreRemover: boolean?)
		if not parsedData.requiresQualifier and not ignoreRemover then
			local extraArgs = parsedData.extraArgumentDescription
			if extraArgs and #extraArgs > 0 then
				table.remove(extraArgs, 1)
			end
		end
		parsedData.requiresQualifier = true
	end

	if parsedDataRequiresQualifier ~= "Sometimes" then
		if parsedDataRequiresQualifier == "Always" then
			enableRequiresQualifier()
		end
	else
		enableRequiresQualifier(true)
		ParsedData.parseQualifierDescription(parsedData)
		parsedData.prematureQualifierParsing = true
		local areAllQualifiersRecognized = #parsedData.qualifierCaptures ~= #parsedData.unrecognizedQualifiers

		if areAllQualifiersRecognized then
			enableRequiresQualifier()
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
						enableRequiresQualifier()
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
	local totalEndless = 0
	if not command then
		return false, totalEndless
	end
	local commandArgs = command.args
	if #commandArgs == 0 then
		return false, totalEndless
	end
	local hasEndless = false
	for _, argNameOrDetail in commandArgs do
		local arg = Args.get(argNameOrDetail) :: any
		if arg and arg.endlessArg == true then
			totalEndless += 1
			hasEndless = true
		end
	end
	return hasEndless, totalEndless
end

function ParsedData.parsedDataSetHasEndlessArgumentFlag(parsedData)
	local givenPrefix = parsedData.givenPrefix
	parsedData.totalEndlessArguments = 0
	for _, capture in parsedData.commandCaptures do
		for commandName, _ in capture do
			local hasEndless, endlessAmount = ParsedData.hasEndlessArgument(commandName, givenPrefix)
			if hasEndless then
				parsedData.totalEndlessArguments += endlessAmount
			end
		end
	end
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
	local totalEndlessArguments = parsedData.totalEndlessArguments or 0
	local haveMoreThanOneEAs = totalEndlessArguments > 1
	if totalEndlessArguments == 0 then
		if not parsedData.requiresQualifier then
			table.insert(parsedData.extraArgumentDescription, 1, parsedData.qualifierDescription)
			parsedData.qualifierDescription = nil
		end
		for _, extraArgument in parsedData.extraArgumentDescription do
			for _, capture in parsedData.commandCaptures do
				for _, arguments in capture do
					table.insert(arguments, extraArgument)
				end
			end
		end
		return
	end

	local foundIndex = 0
	for counter = 1, #allParsedDatas + 1 do
		foundIndex = select(2, string.find(originalMessage, ";", foundIndex + 1))
	end
	foundIndex = select(2, string.find(originalMessage, parsedData.commandDescription, foundIndex + 1, true)) + 2
	if parsedData.requiresQualifier then
		local newFoundIndex = select(2, string.find(originalMessage, parsedData.qualifierDescription, foundIndex, true))
		if newFoundIndex then
			foundIndex = newFoundIndex + 2
		end
	end
	local extraArgumentsBeforeText = math.huge
	local totalHiddenArguments = 0
	for _, capture in parsedData.commandCaptures do
		for commandName, arguments in capture do
			local command = Commands.getCommand(commandName, givenPrefix)
			local commandArgumentNames = command.args

			local firstArgumentNameOrDetail = commandArgumentNames[1]
			local firstArgument = Args.get(firstArgumentNameOrDetail)
			local isPlayerArgument = firstArgument.playerArg == true
			
			-- This primarily helps to account for scenarios where there are *two* or
			-- more endless arguments within a string (e.g. ;poll <title> <fields>).
			local firstEndlessOrHiddenArgPos = nil
			for i, argNameOrDetail in commandArgumentNames do
				local arg = Args.get(argNameOrDetail)
				local isEndless = arg and arg.endlessArg == true
				if isEndless and not firstEndlessOrHiddenArgPos then
					firstEndlessOrHiddenArgPos = i
					break
				end
			end

			-- It also accounts for hidden arguments that come before endless arguments,
			-- where the hidden argument must be ignored when passed through normal means,
			-- such as ";m red hello world", but can be accepted through captures, such as
			-- ";m(red) hello world".
			for i, argNameOrDetail in commandArgumentNames do
				local arg = Args.get(argNameOrDetail)
				local isHiddenButNotPlayerArg = arg and arg.playerArg ~= true and arg.hidden == true
				if isHiddenButNotPlayerArg then
					totalHiddenArguments += 1 -- This is for arg.hidden = true
					firstEndlessOrHiddenArgPos = nil -- Ignore all non-capsule args
				end
			end
			
			local commandArguments = firstEndlessOrHiddenArgPos or #commandArgumentNames
			local capsuleArguments = #arguments

			local commandArgumentsInExtraArguments = commandArguments
				- capsuleArguments
				- (isPlayerArgument and 1 or 0)

			if firstEndlessOrHiddenArgPos then
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
				local valueToAdd = parsedData.extraArgumentDescription[counter]
				table.insert(arguments, valueToAdd)
			end
			for i = 1, totalHiddenArguments do
				if not arguments[i] then
					table.insert(arguments, "")
				end
			end
			table.insert(arguments, extraArgument)
		end
	end

	-- This is a temporary patch to support multiple endless arguments
	-- however is not scalable when ParserSettings.SpaceSeparator is changed.
	-- A re-work of this in the future would be necessary if ParserSettings
	-- are to be moved into configurable SystemSettings
	if haveMoreThanOneEAs then
		local ParserSettings = require(modules.Parser.ParserSettings)
		for _, capture in parsedData.commandCaptures do
			for commandName, arguments in capture do
				local newArguments = {}
				for _, argValue in arguments do
					if typeof(argValue) ~= "string" then
						table.insert(newArguments, argValue)
					end
					local endlessArgsSplit = string.split(argValue, ParserSettings.EndlessArgPattern)
					for _, splitString in endlessArgsSplit do
						table.insert(newArguments, splitString)
					end
				end
				capture[commandName] = newArguments
			end
		end
	end

end


return ParsedData