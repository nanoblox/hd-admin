--!nonstrict
-- LOCAL
local ParserUtility = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local ParserTypes = require(modules.Parser.ParserTypes)
local User = require(modules.Objects.User)
local ConfigSettings = require(modules.Parent.Services.Config.Settings)


-- TYPES
type PlayerSearch = ConfigSettings.PlayerSearch
type Statement = ParserTypes.ParsedStatement


-- FUNCTIONS
-- As name implies, this function will return a table of players that match the
-- given playerString
function ParserUtility.getPlayersFromString(playerString: string, optionalUser: User.Class?): ({Player})
	local selectedPlayers = {}
	local players = game:GetService("Players"):GetPlayers()

	local Config = require(modules.Parent.Services.Config)
	local playerIdentifier = Config.getSetting("PlayerIdentifier", optionalUser)
	local playerDefinedSearch: PlayerSearch = Config.getSetting("PlayerDefinedSearch", optionalUser)
	local playerUndefinedSearch: PlayerSearch = Config.getSetting("PlayerUndefinedSearch", optionalUser)

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


-- Do the incoming strings match a real username?
function ParserUtility.verifyAndParseUsername(callerUser: unknown?, usernameString: string): (boolean, string?)
	if not callerUser or not usernameString then
		return false, nil
	end
	local Config = require(modules.Parent.Services.Config)
	local playerIdentifier = Config.getSetting("PlayerIdentifier", callerUser)

	if string.sub(usernameString, 1, 1) == playerIdentifier then
		-- Is the username defined (e.g @ForeverHD, @ObliviousHD)
		local playerDefinedSearch: PlayerSearch = Config.getSetting("PlayerDefinedSearch", callerUser)
		if playerDefinedSearch == "UserName" or playerDefinedSearch == "UserNameAndDisplayName" then
			return true, string.sub(usernameString, 2)
		end
	else
		-- Is the username undefined (e.g ForeverHD, ObliviousHD)
		local playerUndefinedSearch: PlayerSearch = Config.getSetting("PlayerUndefinedSearch", callerUser)
		if playerUndefinedSearch == "UserName" or playerUndefinedSearch == "UserNameAndDisplayName" then
			return true, usernameString
		end
	end
	return false, nil
end


-- Return all matches in a source using a pattern.
function ParserUtility.getMatches(source, pattern)
	local matches = {}

	for match in string.gmatch(source, pattern) do
		table.insert(matches, match)
	end
	
	return matches
end

function ParserUtility.isQualifiersEmpty(tbl)
	for k,v in pairs(tbl) do
		if k ~= "" then
			return false
		end
	end
	return true
end

-- getCaptures Helper Functions
function ParserUtility.getCapsuleRanges(source)
	local capsuleRanges = {}

	local searchIndex = 0
	while searchIndex ~= nil do
		local open = string.find(source, "%(", searchIndex)
		if open then
			searchIndex = open
			local close = string.find(source, "%)", searchIndex)
			if close then
				searchIndex = close
				table.insert(capsuleRanges, { lower = open, upper = close })
			else
				return nil
			end
		else
			break
		end
	end

	return capsuleRanges
end


--[[

A Capture is found in a source by a table of possible captures and it
includes the arguments in a following capsule if there is any.

A Capture is structured like this [capture] = {[arg1], [arg2], ... }
Captures are structured like this Captures = {[capture1], [capture2], ... }

Returns all the captures found in a source using a sortedKeywords table and
also returns residue (anything left behind in the source after extracting
captures).

]]


function ParserUtility.getCapsuleCaptures(source, sortedKeywords)
	source = source:lower() :: any
	-- Find all the captures
	local captures = {}
	-- We need sorted table so that larger keywords get captured before smaller
	-- keywords so we solve the issue of large keywords made of smaller ones
	for counter = 1, #sortedKeywords do
		-- If the source became empty or whitespace then break
		if string.match(source, "^%s*$") ~= nil then
			break
		end

		-- If the keyword is empty or whitespace (maybe default value?) then continue
		-- to the next iteration
		local keyword = sortedKeywords[counter]:lower() :: string
		if string.match(keyword, "^%s*$") ~= nil then
			continue
		end
		keyword = ParserUtility.escapeSpecialCharacters(keyword)

		-- Used to prevent parsing duplicates
		local alreadyFound = false

		-- Captures with argument capsules are stripped away from the source
		local ParserPatterns = require(modules.Parser.ParserPatterns)
		source = string.gsub(
			source,
			string.format("(%s)%s", keyword, ParserPatterns.capsuleFromKeyword),
			function(keyword, arguments)
				-- Arguments need to be separated as they are the literal string
				-- in the capsule at this point
				if not alreadyFound then
					local separatedArguments = ParserUtility.getMatches(
						arguments,
						ParserPatterns.argumentsFromCollection
					)
					table.insert(captures, { [keyword] = separatedArguments })
				end
				alreadyFound = true
				return ""
			end
		)
	end

	return captures, source
end

function ParserUtility.getPlainCaptures(source, sortedKeywords)
	source = source:lower() :: any

	local captures = {}

	for counter = 1, #sortedKeywords do
		-- If the source became empty or whitespace then break
		if string.match(source, "^%s*$") ~= nil then
			break
		end

		-- If the keyword is empty or whitespace (maybe default value?) then continue
		-- to the next iteration
		local keyword = sortedKeywords[counter]:lower() :: string
		if string.match(keyword, "^%s*$") ~= nil then
			continue
		end
		keyword = ParserUtility.escapeSpecialCharacters(keyword)

		-- Used to prevent parsing duplicates
		local alreadyFound = false

		source = string.gsub(source, keyword, function(keyword, arguments)
			-- Arguments need to be separated as they are the literal string
			-- in the capsule at this point
			if not alreadyFound then
				table.insert(captures, { [keyword] = {} })
			end
			alreadyFound = true
			return ""
		end)
	end

	return captures, source
end

function ParserUtility.combineCaptures(firstCaptures, secondCaptures)
	local combinedCaptures = {}

	for keyword, arguments in pairs(firstCaptures) do
		combinedCaptures[keyword] = arguments
	end

	for keyword, arguments in pairs(secondCaptures) do
		if combinedCaptures[keyword] == nil then
			combinedCaptures[keyword] = arguments
		end
	end

	return combinedCaptures
end

function ParserUtility.escapeSpecialCharacters(source)
	return source:gsub("([%.%%%^%$%(%)%[%]%+%*%-%?])", "%%%1")
end

function ParserUtility.ternary(condition, ifTrue, ifFalse)
	if condition then
		return ifTrue
	else
		return ifFalse
	end
end

function ParserUtility.convertStatementToRealNames(statement: Statement)
	-- We modify the statement to convert all aliases into the actual names for commands and modifiers
	if statement.isConverted == true then
		return
	end
	statement.isConverted = true
	local tablesToConvertToRealNames = {
		["commands"] = {services.Commands, "getCommand"},
		["modifiers"] = {modules.Parser.Modifiers, "get"},
	}
	for tableName, getMethodDetail in tablesToConvertToRealNames do
		local table = statement[tableName]
		if table then
			local getModule = getMethodDetail[1] :: any
			local getReference = require(getModule) :: any
			local getMethod = getReference[getMethodDetail[2]]
			local newTable = {}
			local originalTableName = "original"..tableName:sub(1,1):upper()..tableName:sub(2)
			local originalTable = {}
			for name, value in table do
				local returnValue = getMethod(name)
				local realName = returnValue and (returnValue.aliasOf or returnValue.name)
				local realNameLower = realName and string.lower(realName)
				if realNameLower then
					newTable[realNameLower] = value
				end
				originalTable[name] = true
			end
			statement[originalTableName] = originalTable
			statement[tableName] = newTable
		end
	end
end


return ParserUtility