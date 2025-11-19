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
	local keysToMove = {
		"defaultValue",
		"minValue",
		"maxValue",
		"stepAmount",
	}
	argumentDetail = argumentDetail :: any
	for _, key in keysToMove do
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
	local argNameCorrected = item.name
	if not argToBecome then
		error(`Args: {argNameCorrected} can not become alias because {toBecomeName} is not a valid argument`)
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
local function recordArg(argName: string, argDetail)
	if Args.items[argName] and isServer then
		warn(`HD Admin: Arg '{argName}' already exists. Strongly consider renaming your Custom Arg to avoid conflicts.`)
	end
	Args.items[argName] = argDetail
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

function Args.get(argName: Argument | ArgumentDetail): ArgumentDetail?
	if typeof(argName) == "table" then
		return argName :: ArgumentDetail
	end
	local argNameLower = tostring(argName):lower()
	local ourDictionary = Args.getLowercaseDictionary()
	local item = ourDictionary[argNameLower] :: ArgumentDetail?
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
	for argName, item in Args.items do
		if not item.name then
			item.name = argName :: any
		end
		Args.get(argName :: any)
	end
	local items = Args.items :: { [Argument]: ArgumentDetail }
	return items
end

function Args.create(argumentDetail: ArgumentDetail)
	moveMultiKeysIntoInputObject(argumentDetail)
	processDeveloperArg(argumentDetail)
	local name = argumentDetail.name
	if name then
		recordArg(name, argumentDetail)
	end
	return argumentDetail :: ArgumentDetail
end

function Args.createAliasOf(argName: Argument, argumentDetail: ArgumentDetail?): ArgumentDetail
	if typeof(argumentDetail) ~= "table" then
		argumentDetail = {}
	end
	argumentDetail = argumentDetail :: ArgumentDetail
	task.defer(function()
		-- This servers as a warning as opposed to an actual error
		-- to let the developer know they inputted an invalid argName
		if not Args.items[argName] then
			error(`Args: {argName} is not a valid argument`)
		end
	end)
	if Args.items :: any then
		becomeArg(argumentDetail, argName)
	else
		-- We don't actually create a mirror table here as the data of items will have
		-- not yet gone into memory. Instead, we record the table as an alias, then
		-- set it's data once .get is called or 
		argumentDetail.mustCreateAliasOf = argName
	end
	local name = argumentDetail.name
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
		stringify = function(self, original)

		end,
		parse = function(self, qualifiers: any, callerUserId, additional: any)
			local ParserUtility = require(modules.Parser.ParserUtility)
			local defaultToMe = qualifiers == nil or ParserUtility.isQualifiersEmpty(qualifiers :: any)
			local ignoreDefault = (additional and additional.ignoreDefault)
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
		defaultValue = false,
		playerArg = true,
		runForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId)
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return {players[1]} -- We return as an array as runForEachPlayer is true
		end,
	}),

	["OptionalPlayer"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu. If no player specified, defaults to everyone. This is useful for message commands. For example, you can do ;m others Hello World, AND ;m Hello World",
		playerArg = true,
		hidden = true,
		runForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId)
			local isTableEmpty = require(modules.TableUtil.isTableEmpty)
			local defaultToAll = qualifiers == nil or isTableEmpty(qualifiers)
			if defaultToAll then
				return Players:GetPlayers()
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
			getPickerItemsFromAnyPlayer = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu.",
		defaultValue = {},
		playerArg = true,
		hidden = true,
		runForEachPlayer = false,
		parse = function(self, qualifiers, callerUserId)
			local argPlayer = Args.get("OptionalPlayer" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId) else {}
			return players
		end,
	}),

	["AnyPlayer"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Server & Offline Players",
			getPickerItemsFromAnyPlayer = true,
		},
		inputOptions = {},
		displayName = "userNameOrId",
		description = "Accepts an @userName, displayName, userId or qualifier and returns a userId.",
		defaultValue = 0,
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
		parse = function(self, stringToParse, callerUserId)
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
				local roleDisplayName = string.lower(role.displayName) or roleName
				for selectedRoleName, _ in (roleStringsDict) do
					local nameMatch = string.sub(roleDisplayName, 1, #selectedRoleName) == selectedRoleName
					local keysMatch = roleName == selectedRoleName
					if nameMatch or keysMatch then
						selectedRolesDict[roleName] = role
					end
				end
			end
			local selectedRoles = {}
			for _, role in selectedRolesDict do
				table.insert(selectedRoles, role)
			end
			return selectedRoles
		end,
	}),

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
		parse = function(self, stringToParse)
			return stringToParse
		end,
	}),

	["Code"] = Args.createAliasOf("UnfilteredText"),

	["Number"] = Args.create({
		inputObject = {
			inputType = "NumberInput",
		},
		description = "Accepts a number string and returns a Number",
		defaultValue = 0,
		parse = function(self, stringToParse): number?
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
			local minValue = self.minValue or -math.huge
			local maxValue = self.maxValue or math.huge
			local clampedValue = math.clamp(numberValue, minValue, maxValue)
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

	["AnimationSpeed"] = Args.createAliasOf("Number", register({
		minValue = 0,
		maxValue = 2,
		stepAmount = 0.1,
		defaultValue = 1,
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
		parse = function(self, stringToParse: string): Color3?
			-- This checks for a predefined color term within SystemSettings.colors, such as 'blue', 'red', etc
			local Config = require(modules.Config)
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
			local color3 = hexToColor(stringToParse)
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
		},
		description = "Accepts 'true', 'false', 'yes', 'y', 'no' or 'n' and returns a boolean.",
		defaultValue = false,
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

	["ServersOptions"] = Args.createAliasOf("Options", register({
		inputObject = {
			inputType = "Options",
			optionsArray = {"Current", "All"}
		},
	})),

	["BanLengthOptions"] = Args.createAliasOf("Options", register({
		inputObject = {
			inputType = "Options",
			optionsArray = {"Infinite", "Time"}
		},
	})),

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

	["Tool"] = Args.create({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Tools",
			pickerGetter = function()
				local getTools = require(modules.CommandUtil.getTools)
				local items: {any} = getTools()
				return items
			end,
		},
		displayName = "Tool",
		description = "Accepts a name and returns a copy of any matching tool located in ServerStorage, ReplicatedStorage, StarterPack, Lighting. You MUST Clone this returned tool before using.",
		defaultValue = false,
		parse = function(self, stringToParse): any?
			local getTools = require(modules.CommandUtil.getTools)
			local _, toolLowerNamesDict = getTools()
			if #stringToParse == 0 then
				return nil
			end
			local stringLower = stringToParse:lower()
			local matchingTool = toolLowerNamesDict[stringLower]
			if not matchingTool then
				for toolNameLower, tool in toolLowerNamesDict do
					if string.sub(toolNameLower, 1, #stringToParse) == stringLower then
						matchingTool = tool
						break
					end
				end
			end
			if matchingTool then
				-- We do this to prevent modifications to the original tool
				return {
					Name = matchingTool.Name,
					Clone = function(self)
						return matchingTool:Clone()
					end,
					Destroy = function(self)
						-- Do nothing
					end,
				}
			end
			return nil
		end,
	}),

	["Fields"] = Args.create({
		inputObject = {
			inputType = "InputFields",
			maxItems = 10,
		},
		endlessArg = true,
		defaultValue = "Unnamed Title",
		maxCharacters = TEXT_MAX_CHARACTERS,
		parse = function(self, stringToParse)
			return stringToParse
		end,
	}),

}
Args.items = items


-- SETUP
-- Add the loader args to our items
local loaderItems = LoaderArgs(Args :: any)
for argName, argDetail in loaderItems :: any do
	recordArg(argName, argDetail)
end


-- TYPES
export type Argument = keyof<typeof(items)> | keyof<typeof(loaderItems)>
export type ArgumentDetail = ArgTypes.ArgumentDetail


return Args
