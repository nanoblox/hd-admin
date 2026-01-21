--[[

To do:
	- Consider make inputObject return a function WHICH returns a table, so that
	  callerUserId specific considerations can be made (such as limits)
	  (but first consdier how this works with global networking)
	  
--]]

--!strict
-- CONFIG
local DEFAULT_MAX_CHARACTERS = 100
local TEXT_MAX_CHARACTERS = 420
local KEYS_TO_MOVE_INTO_INPUT_OBJECT = { -- Make sure to also update 'ArgTypes.lua'
		"defaultValue",
		"minValue",
		"maxValue",
		"maxItems",
		"stepAmount",
		"pickerText",
	}


-- LOCAL
local Args = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local hdConfig = script:FindFirstAncestor("HD Admin").Config
local LoaderArgs = require(hdConfig.Args)
local InputObjects = require(modules.Parser.InputObjects)
local ArgTypes = require(modules.Parser.Args.ArgTypes)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local requiresUpdating = true
local sortedNameAndAliasLengthArray = {}
local lowerCaseDictionary = {}
local isServer = RunService:IsServer()
local splitByCollective = require(modules.Parser.splitByCollective)


-- LOCAL FUNCTIONS
local function register(item: ArgumentDetail): ArgumentDetail
	return item :: ArgumentDetail -- We do this to support type checking within the table
end

local function newParse(callback: (...any) -> (...any)): (...any) -> (...any)
	-- This verifies every string so that they are safe
	-- For example, it automatically removes dangerous values like nan nad inf
	return function(self, stringToParse, ...)
		local maxCharacters = self.maxCharacters
		if typeof(stringToParse) ~= "table" then
			-- Arg inputs for Players are already converted from strings to tables so ignore those
			stringToParse = Args.processStringToParse(stringToParse, maxCharacters)
		end
		return callback(self, stringToParse, ...)
	end
end

local function processDeveloperArg(argumentDetail: ArgumentDetail)
	-- This ensures that newParse, etc and all relevant properties are set for
	-- the argumentDetail that is created by the developer
	if typeof(argumentDetail) ~= "table" then
		argumentDetail = {} :: ArgumentDetail
	end
	local parse = argumentDetail.parse
	if typeof(parse) == "function" and argumentDetail.hasUpdatedParse ~= true then
		argumentDetail.hasUpdatedParse = true
		argumentDetail.parse = newParse(parse :: any)
	end
	return argumentDetail
end

local function moveMultiKeysIntoInputObject(argumentDetail: ArgumentDetail)
	if true then
		return
	end
	argumentDetail = argumentDetail :: any
	for _, key in KEYS_TO_MOVE_INTO_INPUT_OBJECT do
		local value = argumentDetail[key]
		if value == nil then
			continue
		end
		local inputObject = argumentDetail.inputObject :: any
		if not argumentDetail.inputObject then
			inputObject = {}
			argumentDetail.inputObject = inputObject
		end
		inputObject[key] = value
	end
	return argumentDetail
end

local function becomeArg(item: ArgumentDetail, toBecomeName: string)
	local argToBecome = Args.items[toBecomeName]
	local argKeyCorrected = item.key
	if not argToBecome then
		error(`Args: {argKeyCorrected} can not become alias because {toBecomeName} is not a valid argument`)
	end
	argToBecome = argToBecome :: any
	item = item :: any
	local deepCopyTable = require(modules.TableUtil.deepCopyTable)
	for k,v in argToBecome do
		if not item[k] then
			if typeof(v) == "table" then
				v = deepCopyTable(v) -- This is essential for example for inputObjects
			end
			item[k] = v
		end
	end
	item.mustCreateAliasOf = nil :: any
	item.aliasOf = toBecomeName
	moveMultiKeysIntoInputObject(item)
	processDeveloperArg(item)
end

local function recordArg(argKey: string, argDetail)
	if Args.items[argKey] and isServer then
		warn(`HD Admin: Arg '{argKey}' already exists. Strongly consider renaming your Custom Arg to avoid conflicts.`)
	end
	Args.items[argKey] = argDetail
end

local function unparsePlayer(tableOfPlayersOrQualifiers: any): string
	-- It's recommended to pass in an array of Players and Qualifiers. E.g:
	-- {Players.ForeverHD, Players.ImAvafe, "others", "role(admin)"}
	if typeof(tableOfPlayersOrQualifiers) == "Instance" and tableOfPlayersOrQualifiers:IsA("Player") then
		tableOfPlayersOrQualifiers = {tableOfPlayersOrQualifiers}
	elseif typeof(tableOfPlayersOrQualifiers) == "string" then
		tableOfPlayersOrQualifiers = {tableOfPlayersOrQualifiers}
	elseif typeof(tableOfPlayersOrQualifiers) ~= "table" then
		tableOfPlayersOrQualifiers = {}
	end
	local PlayerSettings = require(modules.Parser.ParserSettings)
	local getGameSetting = require(modules.CommandUtil.getGameSetting)
	local playerIdentifier = tostring((getGameSetting("PlayerIdentifier") or ""))
	local collective = PlayerSettings.Collective
	local stringsArray: {string} = {}
	for _, playerOrPlayerString in (tableOfPlayersOrQualifiers) do
		local nameString
		if typeof(playerOrPlayerString) == "Instance" and playerOrPlayerString:IsA("Player") then
			-- This could be improved in the future by also accounting for PlayerDefinedSearch
			nameString = playerIdentifier..playerOrPlayerString.Name
		elseif typeof(playerOrPlayerString) == "string" then
			nameString = playerOrPlayerString
		end
		if nameString then
			table.insert(stringsArray, nameString :: string)
		end
	end
	local originalString = table.concat(stringsArray, collective)
	return tostring(originalString)
end

local function parseStringIntoRoles(self, stringToParse): {any}
	if stringToParse == "" or stringToParse == " " then
		return {}
	end
	local roleStrings = splitByCollective(stringToParse)
	local roleStringsDict = {}
	for _, roleString in (roleStrings) do
		roleStringsDict[roleString:lower()] = true
	end
	local Roles = require(modules.Parent.Services.Roles)
	local selectedRolesDict = {}
	for _, role in Roles.getRoles() do
		local roleName = role.name
		if roleStringsDict[roleName:lower()] then
			selectedRolesDict[roleName] = role
			continue
		end
		local roleName = string.lower(role.name) or roleName
		for selectedRoleName, _ in (roleStringsDict) do
			local nameMatch = string.sub(roleName, 1, #selectedRoleName) == selectedRoleName
			local keysMatch = roleName == selectedRoleName
			if nameMatch or keysMatch then
				selectedRolesDict[roleName] = role
			end
		end
	end
	local selectedRoleNames: {any} = {}
	local maxItems = self.inputObject.maxItems or 100
	local totalItems = 0
	for i, role in selectedRolesDict do
		if totalItems >= maxItems then
			break
		end
		totalItems += 1
		table.insert(selectedRoleNames, role)
	end
	return selectedRoleNames
end


-- FUNCTIONS
function Args.update()
	if not requiresUpdating then
		return false
	end
	requiresUpdating = false
	local allItems = Args.getAll()
	sortedNameAndAliasLengthArray = {}
	lowerCaseDictionary = {}
	for itemNameOrAlias, item in pairs(allItems :: any) do
		local lowerCaseName = tostring(itemNameOrAlias):lower()
		lowerCaseDictionary[lowerCaseName] = item
		table.insert(sortedNameAndAliasLengthArray, tostring(itemNameOrAlias))
	end
	table.sort(sortedNameAndAliasLengthArray, function(a: string, b: string): boolean
		return #a > #b
	end)
	return true
end

function Args.getSortedNameAndAliasLengthArray()
	Args.update()
	return sortedNameAndAliasLengthArray
end

function Args.getLowercaseDictionary()
	Args.update()
	return lowerCaseDictionary
end

function Args.processStringToParse(stringToParse: string?, maxCharacters: number?): string
	-- This ensures the string is not abusive or malicious by capping its length,
	-- and removing any nan/infinite/non-standard characters that could be abused
	if typeof(stringToParse) ~= "string" then
		return ""
	end
	local charLimit = if typeof(maxCharacters) == "number" and maxCharacters > 1 then maxCharacters else DEFAULT_MAX_CHARACTERS
	if #stringToParse > charLimit then
		stringToParse = string.sub(stringToParse, 1, charLimit)
	end
	local isNumberSafe = require(modules.VerifyUtil.isNumberSafe)
	if tonumber(stringToParse) and not isNumberSafe(stringToParse) then
		return "0"
	end
	return stringToParse
end

function Args.get(argKey: Argument | ArgumentDetail): ArgumentDetail?
	if typeof(argKey) == "table" then
		return argKey :: ArgumentDetail
	end
	local argKeyLower = tostring(argKey):lower()
	local ourDictionary = Args.getLowercaseDictionary()
	local item = ourDictionary[argKeyLower] :: ArgumentDetail?
	if not item then
		return nil
	end
	local toBecomeName = item.mustCreateAliasOf
	if toBecomeName then
		becomeArg(item, toBecomeName)
	end
	return item :: ArgumentDetail
end

function Args.getAll()
	-- We call .get to ensure all aliases are registered and setup correctly
	for argKey, item in Args.items do
		if not item.key then
			item.key = argKey :: any
		end
		Args.get(argKey :: any)
	end
	local items = Args.items :: { [Argument]: ArgumentDetail }
	return items
end

function Args.create(argumentDetail: ArgumentDetail)
	moveMultiKeysIntoInputObject(argumentDetail)
	processDeveloperArg(argumentDetail)
	local name = argumentDetail.key
	if name then
		recordArg(name, argumentDetail)
	end
	return argumentDetail :: ArgumentDetail
end

function Args.createAliasOf(argKey: Argument, argumentDetail: ArgumentDetail?): ArgumentDetail
	if typeof(argumentDetail) ~= "table" then
		argumentDetail = {}
	end
	argumentDetail = argumentDetail :: ArgumentDetail
	task.defer(function()
		-- This servers as a warning as opposed to an actual error
		-- to let the developer know they inputted an invalid argKey
		if not Args.items[argKey] then
			error(`Args: {argKey} is not a valid argument`)
		end
	end)
	if Args.items :: any then
		becomeArg(argumentDetail, argKey)
	else
		-- We don't actually create a mirror table here as the data of items will have
		-- not yet gone into memory. Instead, we record the table as an alias, then
		-- set it's data once .get is called or 
		argumentDetail.mustCreateAliasOf = argKey
	end
	local name = argumentDetail.key
	if name then
		recordArg(name, argumentDetail)
	end
	return argumentDetail :: ArgumentDetail
end


-- PUBLIC
local items = {

	["Player"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others'), calls the command *for each player*, and returns a single Player instance.",
		playerArg = true,
		runForEachPlayer = true,
		unparse = function(self, arrayOfPlayers: {QualifierInput} | QualifierInput)
			return unparsePlayer(arrayOfPlayers)
		end,
		parse = function(self, qualifiers: any, callerUserId, additional: any)
			local ParserUtility = require(modules.Parser.ParserUtility)
			local defaultToMe = qualifiers == nil or ParserUtility.isQualifiersEmpty(qualifiers :: any)
			local ignoreDefault = if typeof(additional) == "table" then additional.ignoreDefault else nil
			if defaultToMe and not ignoreDefault then
				local players: { Player } = {}
				local callerPlayer = Players:GetPlayerByUserId(callerUserId)
				if callerPlayer then
					table.insert(players, callerPlayer)
				end
				return players
			end
			local targetsDict = {}
			local qualifiersTable = qualifiers or {}
			for qualifierName, qualifierArgs in qualifiersTable do
				if qualifierName == "" then
					continue
				end
				local Qualifiers = require(modules.Parser.Qualifiers)
				local qualifierDetail = Qualifiers.get(qualifierName)
				local targets
				if not qualifierDetail then
					qualifierDetail = Qualifiers.get("Default")
					if qualifierDetail then
						targets = qualifierDetail.getTargets(callerUserId, qualifierName)
					else
						targets = {}
					end	
				else
					targets = qualifierDetail.getTargets(callerUserId, unpack(qualifierArgs :: any))
				end
				for _, plr in pairs(targets) do
					targetsDict[plr] = true
				end
			end
			local players: { Player } = {}
			for plr, _ in pairs(targetsDict) do
				if typeof(plr) == "Instance" and plr:IsA("Player") then
					table.insert(players, plr :: Player)
				end
			end
			return players
		end,
	}),

	["Caller"] = Args.createAliasOf("Player"),

	["Players"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others') and returns an array of Player instances.",
		defaultValue = {},
		playerArg = true,
		runForEachPlayer = false,
		unparse = function(self, arrayOfPlayers: {QualifierInput})
			return unparsePlayer(arrayOfPlayers)
		end,
		parse = function(self, qualifiers, callerUserId)
			local ParserUtility = require(modules.Parser.ParserUtility)
			if ParserUtility.isQualifiersEmpty(qualifiers) then
				return nil
			end
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return players
		end,
	}),

	["SinglePlayer"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
			onlySelectOne = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others') and returns a single Player instance (or nil).",
		defaultValue = {},
		playerArg = true,
		runForEachPlayer = true,
		unparse = function(self, arrayOfPlayers: {QualifierInput} | QualifierInput)
			return unparsePlayer(arrayOfPlayers)
		end,
		parse = function(self, qualifiers, callerUserId)
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return {players[1]} -- We return as an array as runForEachPlayer is true
			--return players[1]
		end,
	}),

	["OptionalPlayer"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu. If no player specified, defaults to me",
		playerArg = true,
		hidden = true,
		runForEachPlayer = true,
		unparse = function(self, arrayOfPlayers: {QualifierInput} | QualifierInput)
			return unparsePlayer(arrayOfPlayers)
		end,
		parse = function(self, qualifiers, callerUserId)
			-- Defaults to ME
			local isTableEmpty = require(modules.TableUtil.isTableEmpty)
			local defaultToMe = qualifiers == nil or isTableEmpty(qualifiers)
			if defaultToMe then
				local players: {Player} = {}
				local callerPlayer = Players:GetPlayerByUserId(callerUserId)
				if callerPlayer then
					table.insert(players, callerPlayer)
				end
				return players
			end
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return players
		end,
	}),

	["OptionalPlayers"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Server & Offline Players",
			getPickerItemsFromAnyUser = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu. This is useful for message commands. For example, you can do ;m others Hello World, AND ;m Hello World",
		defaultValue = {},
		playerArg = true,
		hidden = true,
		runForEachPlayer = false,
		unparse = function(self, arrayOfPlayers: {QualifierInput})
			return unparsePlayer(arrayOfPlayers)
		end,
		parse = function(self, qualifiers, callerUserId)
			local isTableEmpty = require(modules.TableUtil.isTableEmpty)
			local defaultToAll = qualifiers == nil
			if typeof(qualifiers) ~= "table" or isTableEmpty(qualifiers) or qualifiers[""] then
				return nil
			end
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return players
		end,
	}),
	
	["AnyUser"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		inputOptions = {},
		displayName = "userNameOrId",
		description = "Accepts an @userName, displayName, userId or qualifier and returns a userId.",
		defaultValue = 0,
		unparse = function(self, userId: number)
			local whenNumber = tonumber(userId)
			local stringUserId = tostring(whenNumber) or ""
			return stringUserId
		end,
		parse = function(self, stringToParse, callerUserId): number?
			local userId = tonumber(stringToParse)
			if userId then
				return userId
			end
			local playerArg = Args.get("Player")
			local playersInServer = playerArg and playerArg:parse({[stringToParse] = {}}, callerUserId)
			local player = playersInServer[1]
			if player then
				return player.UserId
			end
			local User = require(modules.Objects.User)
			local callerUser = User.getUser(callerUserId)
			local ParserUtility = require(modules.Parser.ParserUtility)
			local approved, username = ParserUtility.verifyAndParseUsername(callerUser, stringToParse)
			if not approved then
				username = stringToParse
			end
			local getUserIdFromNameAsync = require(modules.PlayerUtil.getUserIdFromNameAsync)
			local success, finalUserId = getUserIdFromNameAsync(username :: string)
			if success and typeof(finalUserId) == "number" then
				return finalUserId
			end
			return nil
		end,
	}),

	["Roles"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Leaderstats",
			pickerGetter = function()
				local clientUser = require(modules.References.clientUser)
				local success, roles = clientUser.everyone:fetchAsync("Roles")
				if not roles then
					roles = {}
				end
				return roles :: {any}
			end,
		},
		defaultValue = {},
		description = "Accepts a string and returns a table of roles.",
		unparse = function(self, roleNames: {string} | string)
			local PlayerSettings = require(modules.Parser.ParserSettings)
			local collective = PlayerSettings.Collective
			local arrayOfRoleNames: {string} = {}
			if typeof(roleNames) == "table" then
				arrayOfRoleNames = roleNames
			else
				arrayOfRoleNames = {tostring(roleNames)}
			end
			local rolesToString = table.concat(arrayOfRoleNames, collective)
			return rolesToString
		end,
		parse = function(self, stringToParse, callerUserId)
			return parseStringIntoRoles(self, stringToParse)
		end,
	}),

	["Role"] = Args.createAliasOf("Roles", register({
		maxItems = 1,
		defaultValue = false,
		parse = function(self, stringToParse, callerUserId)
			local roles = parseStringIntoRoles(self, stringToParse)
			local singleRole = roles[1]
			return singleRole
		end,
	})),

	["Text"] = Args.create({
		inputObject = {
			inputType = "TextInput",
			filterText = true,
			preventWhitespaces = false,
		},
		description = "Accepts a string and filters it based upon the caller and target.",
		defaultValue = "",
		endlessArg = true,
		maxCharacters = TEXT_MAX_CHARACTERS,
		unparse = function(self, text: string)
			-- This removes everything in text that contains endlessArgPattern
			local ParserSettings = require(modules.Parser.ParserSettings)
			local endlessArgPattern = ParserSettings.EndlessArgPattern
			local stringSplit = text:split(endlessArgPattern)
			local processedText = table.concat(stringSplit, "")
			return processedText
		end,
		parse = function(self, textToFilter, callerUserId, targetUserId: number?)
			local TextService = game:GetService("TextService")
			local success, result = pcall(function()
				return TextService:FilterStringAsync(textToFilter, callerUserId)
			end)
			if not success then
				return "###"
			end
			local broadcastFiltered: string? = nil
			local function filterForBroadcast()
				if broadcastFiltered then
					return broadcastFiltered
				end
				local success2, filteredText = pcall(function()
					return result:GetNonChatStringForBroadcastAsync()
				end)
				if not success2 then
					return "#####"
				end
				broadcastFiltered = filteredText
				return filteredText
			end
			if not targetUserId then
				return filterForBroadcast()
			end
			local success2, filteredText = pcall(function()
				return result:GetNonChatStringForUserAsync(targetUserId)
			end)
			if not success2 then
				return filterForBroadcast()
			end
			return filteredText
		end,
	}),

	["String"] = Args.createAliasOf("Text"),
	
	["SingleText"] = Args.create({
		inputObject = {
			inputType = "TextInput",
			filterText = true,
			preventWhitespaces = true,
		},
		description = "Accepts a non-endless string (i.e. a string with no whitespace gaps) and filters it based upon the caller and target.",
		defaultValue = "",
		endlessArg = false,
		unparse = function(self, text: string)
			return text
		end,
		parse = function(self, textToFilter)
			return textToFilter
		end,
	}),

	["UnfilteredSingleText"] = Args.create({
		inputObject = {
			inputType = "TextInput",
			filterText = false,
			preventWhitespaces = true,
		},
		description = "Accepts a non-endless string (i.e. a string with no whitespace gaps).",
		defaultValue = "",
		endlessArg = false,
		unparse = function(self, text: string)
			return text
		end,
		parse = function(self, textToFilter)
			return textToFilter
		end,
	}),

	["UnfilteredText"] = Args.create({
		inputObject = {
			inputType = "TextInput",
			filterText = false,
		},
		description = "Accepts a string and returns it unfiltered.",
		defaultValue = "",
		endlessArg = true,
		maxCharacters = TEXT_MAX_CHARACTERS,
		unparse = function(self, text: string)
			return text
		end,
		parse = function(self, stringToParse)
			return stringToParse
		end,
	}),

	["EmoteIdOrName"] = Args.createAliasOf("UnfilteredSingleText"),

	["Code"] = Args.createAliasOf("UnfilteredText"),

	["Number"] = Args.create({
		inputObject = {
			inputType = "NumberInput",
		},
		description = "Accepts a number string and returns a Number",
		defaultValue = 0,
		unparse = function(self, number: number)
			local safeNumberString = Args.processStringToParse(tostring(number))
			return safeNumberString
		end,
		parse = function(self, stringToParse, callerUserId): number?
			-- The stringToParse is already filtered of dangerous numbers thanks to
			-- Args.processStringToParse, so we don't need to worry about size limits
			-- or NaN/Inf values here
			local numberValue = tonumber(stringToParse)
			if not numberValue then
				return nil
			end
			local divAmount = self.divAmount
			if typeof(divAmount) == "number" then
				numberValue = numberValue % divAmount
			end
			local User = require(modules.Objects.User)
			local user = User.getUserByUserId(callerUserId)
			local canBypassLimits = false --!!! RoleService.verifySettings(callerUser).have("bypassLimits")
			local minValue = self.minValue or -math.huge
			local maxValue = self.maxValue or math.huge
			local clampedValue = if canBypassLimits then numberValue else math.clamp(numberValue, minValue, maxValue)
			local stepAmount = self.stepAmount
			if typeof(stepAmount) == "number" then
				local roundToNearest = require(modules.MathUtil.roundToNearest)
				clampedValue = roundToNearest(clampedValue, stepAmount)
			end
			return clampedValue
		end,
	}),

	["Integer"] = Args.createAliasOf("Number", register({
		stepAmount = 1,
	})),

	["Speed"] = Args.createAliasOf("Number", register({
		minValue = 0,
		maxValue = 100,
		stepAmount = 1,
		defaultValue = 10,
	})),

	["Degrees"] = Args.createAliasOf("Number", register({
		description = "Accepts a number and returns a value between 0 and 360.",
		minValue = 0,
		maxValue = 360,
		divAmount = 360,
		stepAmount = 1,
		defaultValue = 180,
	})),

	["Duration"] = Args.create({
		inputObject = {
			inputType = "DurationSelector",
		},
		description = "Accepts a timestring (such as '5s7d8h') and returns the integer equivalent in seconds. Timestring letters are: seconds(s), minutes(m), hours(h), days(d), weeks(w), months(o) and years(y).",
		defaultValue = 0,
		unparse = function(self, seconds: number)
			local value = tonumber(seconds) or 0
			if value < 0 then
				value = 0
			end
			local convertSecondsToTimeString = require(modules.DataUtil.convertSecondsToTimeString)
			return convertSecondsToTimeString(value)
		end,
		parse = function(self, stringToParse)
			local convertTimeStringToSeconds = require(modules.DataUtil.convertTimeStringToSeconds)
			return convertTimeStringToSeconds(stringToParse)
		end,
	}),

	["Color"] = Args.create({
		inputObject = {
			inputType = "ColorPicker",
		},
		description = "Accepts a color name (such as 'red'), a hex code (such as '#FF0000') or an RGB capsule (such as '[255,0,0]') and returns a Color3.",
		defaultValue = Color3.fromRGB(255, 255, 255),
		unparse = function(self, color: Color3)
			if typeof(color) ~= "Color3" then
				color = Color3.fromRGB(255, 255, 255)
			end
			--[[
			-- Remove this method as not compatable with OptionalColor arg which
			-- requires colors within command capsule. For example, ';hint(255,0,0) hello!'
			-- whereas ';hint(255,0,0) hello!' doesn't, because the latter contains
			-- capsule separators (,) which causes the value to be split into multiple args
			local round = require(modules.MathUtil.round)
			local R = round(color.R * 255)
			local G = round(color.G * 255)
			local B = round(color.B * 255)
			local rgbString = `{R},{G},{B}`
			--]]
			local colorToHex = require(modules.DataUtil.colorToHex)
			local rgbString = colorToHex(color)
			return rgbString
		end,
		parse = function(self, stringToParse: string): Color3?
			-- This checks for a predefined color term within SystemSettings.colors, such as 'blue', 'red', etc
			local Config = require(modules.Parent.Services.Config)
			local lowerCommandColors = self.lowerCommandColors
			if not lowerCommandColors then
				local commandColors = Config.getSetting("CommandColors")
				lowerCommandColors = lowerCommandColors or {}
				self.lowerCommandColors = lowerCommandColors
				for colorName, color in commandColors do
					colorName = tostring(colorName)
					lowerCommandColors[colorName:lower()] = color
				end
			end
			local color3FromName = lowerCommandColors[stringToParse:lower()]
			if color3FromName then
				return color3FromName
			end
			-- This checks for an RGB capsule which will look like 'R,G,B' or 'R, G, B' (the square brackets are stripped within the Parser module)
			local rgbTable = stringToParse:gsub(" ", ""):split(",")
			if rgbTable then
				local r = tonumber(rgbTable[1])
				local g = tonumber(rgbTable[2])
				local b = tonumber(rgbTable[3])
				if r and g and b then
					return Color3.fromRGB(r, g, b)
				end
			end
			-- This checks if the string is a Hex Code (such as #FF5733)
			if stringToParse:sub(1,1) ~= "#" then
				stringToParse = "#" .. stringToParse
			end
			local hexValue = stringToParse:sub(2, #stringToParse)
			local hexToColor = require(modules.DataUtil.hexToColor)
			local color3 = #stringToParse > 2 and hexToColor(stringToParse)
			if color3 then
				return color3
			end
			return nil
		end,
	}), 

	["Colour"] = Args.createAliasOf("Color"),

	["OptionalColor"] = Args.createAliasOf("Color", register({
		description = "Same as 'Color' but but must be wrapped in a command capsule. E.g. ';message(yellow) Hello World!'",
		defaultValue = Color3.fromRGB(255, 255, 255),
		hidden = true,
	})),

	["Bool"] = Args.create({
		inputObject = {
			inputType = "Toggle",
			pickerText = "This describes the toggle",
		},
		description = "Accepts 'true', 'false', 'yes', 'y', 'no' or 'n' and returns a boolean.",
		defaultValue = false,
		unparse = function(self, bool: boolean)
			if bool == true then
				return "true"
			else
				return "false"
			end	
		end,
		parse = function(self, stringToParse): boolean?
			local stringLower = stringToParse:lower()
			local trueStrings = {
				["true"] = true,
				["t"] = true,
				["yes"] = true,
				["y"] = true,
			}
			local falseStrings = {
				["false"] = true,
				["f"] = true,
				["no"] = true,
				["n"] = true,
			}
			if trueStrings[stringLower] then
				return true
			elseif falseStrings[stringLower] then
				return false
			end
			return nil
		end,
	}),

	["Toggle"] = Args.createAliasOf("Bool"),

	["Options"] = Args.create({
		inputObject = {
			inputType = "Options",
			optionsArray = {"Yes", "No"},
		},
		description = "Accepts any value within the optionsArray and returns the value.",
		unparse = function(self, option: string)
			return option
		end,
		parse = function(self, stringToParse)
			local stringLower = stringToParse:lower()
			local stringLen = #stringLower :: any
			local optionsArray: {any} = self.inputObject.optionsArray or {}
			for _, option in optionsArray do
				if option:lower():sub(1,stringLen) == stringLower then
					return option
				end
			end
			local defaultValue = optionsArray[1] or "Empty"
			return defaultValue
		end,
	}),

	["Leaderstat"] = Args.create({
		-- Accepts the names of stats within the player's leaderstats:
		-- https://create.roblox.com/docs/players/leaderboards
		-- Leaderstats may not exist within the player, so must be checked for
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Leaderstats",
			pickerGetter = function()
				-- Return array of leaderstat names from player's leaderstats
				local items: {any} = {}
				local localPlayer = Players.LocalPlayer
				local leaderstats = localPlayer:FindFirstChild("leaderstats")
				if not leaderstats then
					return items
				end
				for _, childStat in pairs(leaderstats:GetChildren()) do
					table.insert(items, childStat.Name)
				end
				return items
			end,
		},
		description = "Accepts a valid stat name and returns the stat (defined in Server/Modules/StatHandler)",
		defaultValue = false,
		unparse = function(self, leaderstat: Instance?)
			if typeof(leaderstat) == "Instance" then
				return leaderstat.Name
			end
			return ""
		end,
		parse = function(self, stringToParse, callerUserId, targetUserId: number?): Instance?
			local userIdToFind = tonumber(targetUserId or callerUserId)
			local targetPlayer = userIdToFind and Players:GetPlayerByUserId(userIdToFind)
			if not targetPlayer then
				return nil
			end
			local leaderstats = targetPlayer:FindFirstChild("leaderstats") or targetPlayer:FindFirstChild("Leaderstats")
			if not leaderstats then
				return nil
			end
			local stringLower = string.lower(stringToParse)
			for _, childStat in pairs(leaderstats:GetChildren()) do
				if string.lower(childStat.Name) == stringLower then
					return childStat
				end
			end
			for _, childStat in pairs(leaderstats:GetChildren()) do
				if string.sub(string.lower(childStat.Name), 1, #stringLower) == stringLower then
					return childStat
				end
			end
			return nil
		end,
	}),

	["Team"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Teams",
			pickerGetter = function()
				-- Return array of team names with game.Teams
				local items: {any} = {}
				local Teams = game:GetService("Teams")
				for _, team in pairs(Teams:GetChildren()) do
					if team:IsA("Team") then
						table.insert(items, team.Name)
					end
				end
				return items
			end,
		},
		displayName = "TeamName",
		description = "Accepts a valid team name and returns the team instance.",
		defaultValue = false,
		unparse = function(self, team: Team?)
			if typeof(team) == "Instance" then
				return team.Name
			end
			return ""
		end,
		parse = function(self, stringToParse): Team?
			local Teams = game:GetService("Teams")
			local stringToParseLower = string.lower(stringToParse)
			if string.len(stringToParseLower) > 0 then
				for _, team in pairs(Teams:GetChildren()) do
					local teamName = string.lower(team.Name)
					if team:IsA("Team") and string.sub(teamName, 1, #stringToParseLower) == stringToParseLower then
						return team
					end
				end
			end
			return nil
		end,
	}),

	["Material"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Materials",
			pickerGetter = function()
				-- Return array of all possible material enums
				local items: {any} = Enum.Material:GetEnumItems()
				return items
			end,
		},
		description = "Accepts a valid material and returns a Material enum.",
		defaultValue = Enum.Material.Plastic,
		unparse = function(self, material: Enum.Material?)
			if typeof(material) == "EnumItem" then
				return material.Name
			end
			return ""
		end,
		parse = function(self, stringToParse): Enum.Material?
			local materialEnumNamesLowercase = self.materialEnumNamesLowercase
			if not materialEnumNamesLowercase then
				materialEnumNamesLowercase = {}
				self.materialEnumNamesLowercase = materialEnumNamesLowercase
				for _, enumItem in Enum.Material:GetEnumItems() do
					materialEnumNamesLowercase[enumItem.Name:lower()] = enumItem :: any
				end
			end
			local stringLower = stringToParse:lower()
			local enumItem = materialEnumNamesLowercase[stringLower]
			if enumItem then
				return enumItem
			end
			for enumNameLower, enumItem in materialEnumNamesLowercase do
				if string.sub(enumNameLower, 1, #stringToParse) == stringLower then
					return enumItem
				end
			end
			return nil
		end,
	}),

	["Tools"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Tools",
			pickerGetter = function()
				local getTools = require(modules.CommandUtil.getTools)
				local items: {any} = getTools()
				return items
			end,
		},
		displayName = "ToolName",
		description = "Accepts a name and returns a copy of any matching tools located in ServerStorage, ReplicatedStorage, StarterPack, Lighting. You MUST Clone the returned tool before using.",
		defaultValue = {},
		unparse = function(self, tool: Instance?)
			if typeof(tool) == "Instance" or (typeof(tool) == "table" and typeof(tool.Name) == "string") then
				return tool.Name
			end
			return ""
		end,
		parse = function(self, stringToParse): any?
			local getTools = require(modules.CommandUtil.getTools)
			local _, toolLowerNamesDict = getTools()
			if #stringToParse == 0 then
				return nil
			end
			local stringLower = stringToParse:lower()
			local toolsDict = {}
			for toolNameLower, tool in toolLowerNamesDict do
				if stringLower == "all" or string.sub(toolNameLower, 1, #stringToParse) == stringLower or toolNameLower:match(stringLower) then
					toolsDict[tool] = true
				end
			end
			local toolsArray: {any} = {}
			for tool, _ in toolsDict do
				table.insert(toolsArray, tool)
			end
			return toolsArray
		end,
	}),

	["Fields"] = Args.create({
		inputObject = {
			inputType = "InputFields",
			maxItems = 10,
		},
		endlessArg = true,
		defaultValue = {},
		maxCharacters = TEXT_MAX_CHARACTERS,
		unparse = function(self, optionsArray: {string})
			local ParserSettings = require(modules.Parser.ParserSettings)
			local endlessFieldsPattern = ParserSettings.EndlessFieldsPattern
			local joinedString = table.concat(optionsArray, endlessFieldsPattern)
			return joinedString
		end,
		parse = function(self, stringToParse): {string}?
			if typeof(stringToParse) ~= "string" then
				return nil
			end
			local ParserSettings = require(modules.Parser.ParserSettings)
			local endlessArgsSplit = string.split(stringToParse, ParserSettings.EndlessFieldsPattern)
			return endlessArgsSplit
		end,
	}),

}
Args.items = items


-- SETUP
-- Add the loader args to our items
local loaderItems = LoaderArgs(Args :: any)
for argKey, argDetail in loaderItems :: any do
	recordArg(argKey, argDetail)
end


-- TYPES
export type Argument = keyof<typeof(items)> | keyof<typeof(loaderItems)>
export type ArgumentDetail = ArgTypes.ArgumentDetail
type QualifierInput = Player | string


return Args
