--[[
	To do:
	- Complete Modifiers
	- Complete Args
	- Upload to GitHub
	- Support 'CommandService' alternative and build into Parser
	- Support 'SettingService' alternative and build into Parser
	- Complete this (and make fully typed)
	- Complete Algorithm (make fully typed)
	- Complete ParserUtility (make fully typed)
	- Begin extensive testing
]]


--!strict
-- LOCAL
local Parser = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local MAIN = nil :: any


-- TYPES
export type QualifierRequired = "Always" | "Sometimes" | "Never"
export type PlayerSearch = "None" | "UserName" | "DisplayName" | "UserNameAndDisplayName"


-- FUNCTIONS
function Parser.init()
	local ClientSettings = MAIN.services.SettingService.getGroup("Client")

	Parser.patterns = {
		commandStatementsFromBatch = string.format(
			"%s([^%s]+)",
			";", --ClientSettings.prefix,
			";" --ClientSettings.prefix
		),
		descriptionsFromCommandStatement = string.format(
			"%s?([^%s]+)",
			" ", --ClientSettings.descriptorSeparator,
			" " --ClientSettings.descriptorSeparator
		),
		argumentsFromCollection = string.format(
			"([^%s]+)%s?",
			",", --ClientSettings.collective,
			"," --ClientSettings.collective
		),
		capsuleFromKeyword = string.format(
			"%%(%s%%)", --Capsule
			string.format("(%s)", ".-")
		),
	}
end

--[[

Analyzes the given command name to determine whether or not it's appearance in a
commandstatement mandates that commandstatement to require a qualifierdescription
to be considered valid.

It is not always possible to determine qualifierdescription requirement solely from
the command name or the data associated with it but rather has to be confirmed further
from the information of the commandstatement it appears in.

1) If every argument for the command has playerArg ~= true then returns QualifierRequired.Never

2) If even one argument for the command has playerArg == true and hidden ~= true returns
	QualifierRequired.Always

3) If condition (1) and condition (2) are not satisfied, meaning every argument for
	the command has playerArg == true and hidden == true returns QualifierRequired.Sometimes

]]

function Parser.requiresQualifier(commandName)
	local commandArgs = MAIN.services.CommandService.getTable("lowerCaseNameAndAliasToCommandDictionary")[commandName].args
	if #commandArgs == 0 then
		return "Never"
	end
	local firstArgName = commandArgs[1]:lower() --!!! re-do this
	local Args = require(script.Args)
	local firstArg = Args.get(firstArgName)
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


function Parser.hasEndlessArgument(commandName)
	local Args = require(script.Args)
	local argsDictionary = Args.getAll()
	local commandArgs =
		MAIN.services.CommandService.getTable("lowerCaseNameAndAliasToCommandDictionary")[commandName].args
	if #commandArgs == 0 then
		return false
	end
	local lastArgName = commandArgs[#commandArgs]:lower()
	local lastArg = argsDictionary[lastArgName] :: any
	local bool = if lastArg and lastArg.endlessArg == true then true else false
	return bool
end


function Parser.getPlayersFromString(playerString, optionalUser)
	local selectedPlayers = {}
	local ParserUtility = require(script.ParserUtility)
	local settingService = MAIN.services.SettingService
	local players = game:GetService("Players"):GetPlayers()

	local playerIdentifier = settingService.getUsersPlayerSetting(optionalUser, "playerIdentifier")
	local playerDefinedSearch = settingService.getUsersPlayerSetting(optionalUser, "playerDefinedSearch")
	local playerUndefinedSearch = settingService.getUsersPlayerSetting(optionalUser, "playerUndefinedSearch")

	local hasPlayerIdentifier = (playerString:sub(1, 1) == playerIdentifier)
	playerString = playerString:lower()
	local playerStringWithoutIdentifier = ParserUtility.ternary(
		hasPlayerIdentifier,
		playerString:sub(2, #playerString),
		playerString
	)

	local isUserNameSearch = ParserUtility.ternary(
		hasPlayerIdentifier,
		playerDefinedSearch == "UserName",
		playerUndefinedSearch == "UserName"
	)
	local isDisplayNameSearch = ParserUtility.ternary(
		hasPlayerIdentifier,
		playerDefinedSearch == "DisplayName",
		playerUndefinedSearch == "DisplayName"
	)
	local isUserNameAndDisplayNameSearch = ParserUtility.ternary(
		hasPlayerIdentifier,
		playerDefinedSearch == "UserNameAndDisplayName",
		playerUndefinedSearch == "UserNameAndDisplayName"
	)

	if isUserNameSearch or isUserNameAndDisplayNameSearch then
		for _, player in pairs(players) do
			if string.find(player.Name:lower(), playerStringWithoutIdentifier) == 1 then
				if table.find(selectedPlayers, player) == nil then
					table.insert(selectedPlayers, player)
				end
			end
		end
	end

	if isDisplayNameSearch or isUserNameAndDisplayNameSearch then
		for _, player in pairs(players) do
			if string.find(player.DisplayName:lower(), playerStringWithoutIdentifier) == 1 then
				if table.find(selectedPlayers, player) == nil then
					table.insert(selectedPlayers, player)
				end
			end
		end
	end

	return selectedPlayers
end


function Parser.verifyAndParseUsername(callerUser, usernameString: string): (boolean, string?)
	if not callerUser or not usernameString then
		return false, nil
	end
	local playerIdentifier = MAIN.services.SettingService.getUsersPlayerSetting(callerUser, "playerIdentifier")
	if string.sub(usernameString, 1, 1) == playerIdentifier then
		-- Is the username defined (e.g @ForeverHD, @ObliviousHD)
		local playerDefinedSearch = MAIN.services.SettingService.getUsersPlayerSetting(callerUser, "playerDefinedSearch")
		if playerDefinedSearch == "UserName" or playerDefinedSearch == "UserNameAndDisplayName" then
			return true, string.sub(usernameString, 2)
		end
	else
		-- Is the username undefined (e.g ForeverHD, ObliviousHD)
		local playerUndefinedSearch = MAIN.services.SettingService.getUsersPlayerSetting(callerUser, "playerUndefinedSearch")
		if playerUndefinedSearch == "UserName" or playerUndefinedSearch == "UserNameAndDisplayName" then
			return true, usernameString
		end
	end
	return false, nil
end


function Parser.parseMessage(message, optionalUser)
	local Algorithm = require(script.Algorithm)
	local ParsedData = require(script.ParsedData)
	local allParsedDatas = {}
	--[[
	for _, commandStatement in pairs(Algorithm.getCommandStatementsFromBatch(message)) do
		
		-- Step 1
		local parsedData = ParsedData.generateEmptyParsedData()
		parsedData.commandStatement = commandStatement

		-- Step 2
		ParsedData.parseCommandStatement(parsedData)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData)
			continue
		end

		-- Step 3
		ParsedData.parseCommandDescriptionAndSetFlags(parsedData, optionalUser)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData)
			continue
		end

		-- Step 4
		ParsedData.parseQualifierDescription(parsedData)
		if not parsedData.isValid then
			table.insert(allParsedDatas, parsedData)
			continue
		end

		-- Step 5
		ParsedData.parseExtraArgumentDescription(parsedData, allParsedDatas, message)
		table.insert(allParsedDatas, parsedData)
		if parsedData.hasTextArgument then
			break
		end
	end

	--!! Potential Step 6
	return ParsedData.generateOrganizedParsedData(allParsedDatas)
	--]]
end


return Parser