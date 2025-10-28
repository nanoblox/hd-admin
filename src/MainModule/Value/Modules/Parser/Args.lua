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
local InputObjects = require(modules.Parser.InputObjects)
local Players = game:GetService("Players")
local requiresUpdating = true
local sortedNameAndAliasLengthArray = {}
local lowerCaseDictionary = {}

-- LOCAL FUNCTIONS
local function register(item: ArgumentDetail): ArgumentDetail
	return item :: ArgumentDetail -- We do this to support type checking within the table
end
local function newParse(callback: (...any) -> (...any)): (...any) -> (...any)
	-- This verifies every string so that they are safe
	return function(self, stringToParse, ...)
		local maxCharacters = self.maxCharacters
		stringToParse = Args.processStringToParse(stringToParse, maxCharacters)
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
	if typeof(parse) == "function" then
		parse = newParse(parse :: any)
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
	for k,v in argToBecome do
		if not item[k] then
			item[k] = v
		end
	end
	item.mustCreateAliasOf = nil :: any
	item.aliasOf = toBecomeName
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
	local name = argumentDetail.name
	processDeveloperArg(argumentDetail)
	if name then
		Args.items[name] = argumentDetail :: any
	end
	return argumentDetail
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
		processDeveloperArg(argumentDetail)
		becomeArg(argumentDetail, argName)
	else
		-- We don't actually create a mirror table here as the data of items will have
		-- not yet gone into memory. Instead, we record the table as an alias, then
		-- set it's data once .get is called or 
		argumentDetail.mustCreateAliasOf = argName
	end
	return argumentDetail
end

-- PUBLIC
local items = {

	["Player"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others'), calls the command *for each player*, and returns a single Player instance.",
		playerArg = true,
		executeForEachPlayer = true,
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

	["Players"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others') and returns an array of Player instances.",
		defaultValue = {},
		playerArg = true,
		executeForEachPlayer = false,
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

	["SinglePlayer"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
			onlySelectOne = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others') and returns a single Player instance (or nil).",
		defaultValue = false,
		playerArg = true,
		executeForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId)
			local argPlayer = Args.get("Player" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId, {ignoreDefault = true}) else {}
			return {players[1]} -- We return as an array as executeForEachPlayer is true
		end,
	}),

	["OptionalPlayer"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu. If no player specified, defaults to everyone. This is useful for message commands. For example, you can do ;m others Hello World, AND ;m Hello World",
		playerArg = true,
		hidden = true,
		executeForEachPlayer = true,
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

	["OptionalPlayers"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Server & Offline Players",
			getPickerItemsFromAnyPlayer = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu.",
		defaultValue = {},
		playerArg = true,
		hidden = true,
		executeForEachPlayer = false,
		parse = function(self, qualifiers, callerUserId)
			local argPlayer = Args.get("OptionalPlayer" :: any)
			local players = if argPlayer then argPlayer:parse(qualifiers, callerUserId) else {}
			return players
		end,
	}),

	["AnyPlayer"] = register({
		-- Accepts qualifiers ("me", "all", "others") or players within game.Players
		-- Accepts an Integer OR String OR Qualifier ("me", "all", "others")
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Server & Offline Players",
			getPickerItemsFromAnyPlayer = true,
		},
		inputOptions = {},
		displayName = "userNameOrId",
		description = "Accepts an @userName, displayName, userId or qualifier and returns a userId.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse, callerUserId)
			--[[
			local callerUser = main.modules.PlayerStore:getUserByUserId(callerUserId)
			local playersInServer = Args.get("Player"):parse({[stringToParse] = {}}, callerUserId) --ParserUtility.getPlayersFromString(stringToParse, callerUser)
			local player = playersInServer[1]
			if player then
				return player.UserId
			end
			local userId = tonumber(stringToParse)
			if userId then
				return userId
			end
			local approved, username = ParserUtility.verifyAndParseUsername(callerUser, stringToParse)
			local success, finalUserId
			if approved then
				success, finalUserId = main.modules.PlayerUtil.getUserIdFromName(username):await()
			end
			if success then
				return finalUserId
			end
			--]]
		end),
	}),

	["Roles"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Leaderstats",
			pickerItems = function()
				-- Return array of all roles in game
				return {}
			end,
		},
		description = "Accepts a string and returns a table of roles.",
	}),

	["Text"] = register({
		inputObject = {
			inputType = "TextInput",
			filterText = true,
			preventWhitespaces = false,
		},
		description = "Accepts a string and filters it based upon the caller and target.",
		defaultValue = "",
		endlessArg = true,
		maxCharacters = TEXT_MAX_CHARACTERS,
		parse = newParse(function(self, textToFilter, callerUserId, targetUserId: number?)
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
		end),
	}),

	["String"] = Args.createAliasOf("Text"),
	
	["SingleText"] = register({
		inputObject = {
			inputType = "TextInput",
			filterText = true,
			preventWhitespaces = true,
		},
		description = "Accepts a non-endless string (i.e. a string with no whitespace gaps) and filters it based upon the caller and target.",
		defaultValue = "",
		endlessArg = false,
		parse = newParse(function(self, textToFilter)
			return textToFilter
		end),
	}),

	["UnfilteredText"] = register({
		inputObject = {
			inputType = "TextInput",
			filterText = false,
		},
		description = "Accepts a string and returns it unfiltered.",
		defaultValue = "",
		endlessArg = true,
		maxCharacters = TEXT_MAX_CHARACTERS,
		parse = newParse(function(self, stringToParse)
			return stringToParse
		end),
	}),

	["Code"] = Args.createAliasOf("UnfilteredText"),

	["Number"] = register({
		inputObject = {
			inputType = "NumberInput",
		},
		description = "Accepts a number string and returns a Number",
		defaultValue = 0,
		parse = newParse(function(self, stringToParse)
			-- The stringToParse is already filtered of dangerous numbers thanks to
			-- Args.processStringToParse, so we don't need to worry about size limits
			-- or NaN/Inf values here
			return tonumber(stringToParse)
		end),
	}),

	["Integer"] = Args.createAliasOf("Number", register({
		inputObject = {
			inputType = "NumberInput",
			stepAmount = 1,
		},
	})),

	["Scale"] = Args.createAliasOf("Number", register({
		inputObject = {
			inputType = "NumberInput",
			minValue = 0,
			maxValue = 5,
		},
		description = "Accepts a number and returns a number which is considerate of scale limits.",
		defaultValue = 1,
		parse = newParse(function(self, stringToParse)
			--local scaleValue = tonumber(stringToParse)
			--return scaleValue
		end),
		verifyCanUse = function(self, callerUser, valueToParse)
			--[[
			-- Check valid number
			local scaleValue = tonumber(valueToParse)
			if not scaleValue then
				return false, string.format("'%s' must be a number instead of '%s'!", self.name, tostring(valueToParse))
			end
			-- Check has permission to use scale value
			local RoleService = main.services.RoleService
			if RoleService.verifySettings(callerUser, "limit.whenScaleCapEnabled").areAll(true) then
				local scaleLimit = RoleService.getMaxValueFromSettings(callerUser, "limit.scaleCapAmount")
				if scaleValue > scaleLimit then
					return false, ("Cannot exceed scale limit of '%s'. Your value was '%s'."):format(scaleLimit, scaleValue)
				end
			end
			return true
			--]]
			end,
		})
	),

	["Speed"] = Args.createAliasOf("Number", register({
		inputObject = {
			inputType = "NumberSlider",
			minValue = 0,
			maxValue = 100,
			stepAmount = 1
		},
		defaultValue = 1,
	})),

	["AnimationSpeed"] = Args.createAliasOf("Number", register({
		inputObject = {
			inputType = "NumberSlider",
			minValue = 0,
			maxValue = 5,
			stepAmount = 0.1
		},
		defaultValue = 1,
	})),

	["Degrees"] = register({
		inputObject = {
			inputType = "NumberSlider",
			minValue = 0,
			maxValue = 360,
			stepAmount = 1,
		},
		description = "Accepts a number and returns a value between 0 and 360.",
		defaultValue = 0,
		--[[
		parse = newParse(function(self, stringToParse): number?
			local number = tonumber(stringToParse)
			if number then
				return number % 360
			end
			return nil
		end),
		--]]
	}),

	["Duration"] = register({
		inputObject = {
			inputType = "DurationSelector",
		},
		description = "Accepts a timestring (such as '5s7d8h') and returns the integer equivalent in seconds. Timestring letters are: seconds(s), minutes(m), hours(h), days(d), weeks(w), months(o) and years(y).",
		defaultValue = 0,
		parse = newParse(function(self, stringToParse)
			--return main.modules.DataUtil.convertTimeStringToSeconds(tostring(stringToParse))
		end),
	}),

	["Color"] = register({
		inputObject = {
			inputType = "ColorPicker",
		},
		description = "Accepts a color name (such as 'red'), a hex code (such as '#FF0000') or an RGB capsule (such as '[255,0,0]') and returns a Color3.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse)
			--[[
			-- This checks for a predefined color term within SystemSettings.colors, such as 'blue', 'red', etc
			local lowerCaseColors = main.services.SettingService.getLowerCaseColors()
			local color3FromName = lowerCaseColors[stringToParse:lower()]
			if color3FromName then
				return color3FromName
			end
			-- This checks if the string is a Hex Code (such as #FF5733)
			if stringToParse:sub(1,1) == "#" then
				local hexValue = stringToParse:sub(2)
				if hexValue then
					local hex = "#"..hexValue
					local color3 = main.modules.DataUtil.hexToColor3(hex)
					return color3
				end
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
			--]]
		end),
	}), 

	["Colour"] = Args.createAliasOf("Color"),

	["Gradient"] = Args.createAliasOf("Color"),

	["OptionalColor"] = Args.createAliasOf("Color", register({
		description = "Accepts a color name (such as 'red'), a hex code (such as '#FF0000') or an RGB capsule (such as '[255,0,0]') and returns a Color3.",
		defaultValue = Color3.fromRGB(255, 255, 255),
		hidden = true,
	})),

	["Bool"] = register({
		inputObject = {
			inputType = "Toggle",
		},
		description = "Accepts 'true', 'false', 'yes', 'y', 'no' or 'n' and returns a boolean.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse)
			--[[
			local trueStrings = {
				["true"] = true,
				["yes"] = true,
				["y"] = true,
			}
			local falseStrings = {
				["false"] = true,
				["no"] = true,
				["n"] = true,
			}
			if trueStrings[stringToParse] then
				return true
			elseif falseStrings[stringToParse] then
				return false
			end
			--]]
		end),
	}),

	["Toggle"] = Args.createAliasOf("Bool"),

	["Options"] = register({
		inputObject = {
			inputType = "Options",
			optionsArray = { "Yes", "No" },
		},
		description = "Accepts any value within the optionsArray and returns the value.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse)
			
		end),
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
			optionsArray = {"∞", "Time"}
		},
	})),

	["Leaderstat"] = register({
		-- Accepts the names of stats within the player's leaderstats:
		-- https://create.roblox.com/docs/players/leaderboards
		-- Leaderstats may not exist within the player, so must be checked for
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Leaderstats",
			pickerItems = function()
				-- Return array of leaderstat names from player's leaderstats
				-- To-do later
				return {}
			end,
		},
		description = "Accepts a valid stat name and returns the stat (defined in Server/Modules/StatHandler). This requires the 'player' arg as the first argument to work.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse, _, targetUserId)
			--[[
			local targetPlayer = Players:GetPlayerByUserId(targetUserId)
			local stat = (targetPlayer and main.modules.StatHandler.get(targetPlayer, stringToParse))
			return stat
			--]]
		end),
	}),

	["Team"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Teams",
			pickerItems = function()
				-- Return array of team names with game.Teams
				-- To-do later
				return {}
			end,
		},
		displayName = "TeamName",
		description = "Accepts a valid team name and returns the team instance.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse)
			--[[
			local stringToParseLower = string.lower(stringToParse)
			if string.len(stringToParseLower) > 0 then
				for _,team in pairs(main.Teams:GetChildren()) do
					local teamName = string.lower(team.Name)
					if string.sub(teamName, 1, #stringToParseLower) == stringToParseLower then
						return team
					end
				end
			end
			--]]
		end),
	}),

	["Material"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Materials",
			pickerItems = function()
				-- Return array of all possible material enums
				-- To-do later
				return {}
			end,
		},
		description = "Accepts a valid material and returns a Material enum.",
		defaultValue = false,
		parse = newParse(function(self, stringToParse)
			--[[
			local enumItem = materialEnumNamesLowercase[stringToParse:lower()]
			if enumItem then
				return enumItem
			end
			--]]
		end),
	}),

	["Gear"] = register({
		inputObject = {
			inputType = "NumberInput",
		},
		displayName = "GearId",
		description = "Accepts a gearId (aka a CatalogId) and returns the Tool instance if valid. Do not use the returned Tool instance, clone it instead.",
		defaultValue = false,
		--[[
		parse = newParse(function(self, stringToParse)
			local storageDetail = Args.getStorage(self.name)
			local cachedItem = storageDetail:get(stringToParse)
			if cachedItem then
				return cachedItem
			end
			local success, model = main.services.AssetService.loadAsset(stringToParse)
			if not success then
				return
			end
			local tool = model:FindFirstChildOfClass("Tool")
			if tool then
				storageDetail:cache(stringToParse, tool)
			end
			model:Destroy()
			return tool
		end),
		verifyCanUse = function(self, callerUser, valueToParse)
			-- Check if valid string
			local stringToParse = tostring(valueToParse)
			local gearIdString = string.match(stringToParse, "%d+")
			local gearId = tonumber(gearIdString)
			if not gearId then
				return false, string.format("'%s' is an invalid ID!", stringToParse)
			end
			-- Check if restricted to user
			local approved, warning = main.services.SettingService.verifyCanUseRestrictedID(callerUser, "libraryAndCatalog", gearIdString)
			if not approved then
				return false, warning
			end
			-- Check if correct asset type
			local assetType = main.modules.ProductUtil.getAssetTypeAsync(gearId, Enum.InfoType.Asset)
			if assetType ~= Enum.AssetType.Gear.Value then
				return false, string.format("'%s' is not a valid GearID!", gearId)
			end
			return true
		end,
		--]]
	}),

	["BundleDescription"] = register({
		inputObject = {
			inputType = "NumberInput",
		},
		displayName = "BundleId",
		description = "Accepts a bundleId and returns a HumanoidDescription associated with that bundle.",
		defaultValue = false,
		--[[
		parse = newParse(function(self, stringToParse, _, targetUserId)
			local humanoid = main.modules.PlayerUtil.getHumanoid(targetUserId)
			local success, description = main.modules.MorphUtil.getDescriptionFromBundleId(stringToParse, humanoid):await()
			if not success then
				return
			end
			return description
		end),
		verifyCanUse = function(self, callerUser, valueToParse)
			-- Check if valid string
			local stringToParse = tostring(valueToParse)
			local bundleIdString = string.match(tostring(stringToParse), "%d+")
			local bundleId = tonumber(bundleIdString)
			if not bundleId then
				return false, string.format("'%s' is an invalid ID!", stringToParse)
			end
			-- Check if restricted to user
			local approved, warning = main.services.SettingService.verifyCanUseRestrictedID(callerUser, "bundle", bundleIdString)
			if not approved then
				return false, warning
			end
			-- Check bundle exists
			local success, warning2 = main.modules.MorphUtil.loadBundleId(valueToParse):await()
			return success, warning2
		end,
		--]]
	}),

	["UserDescription"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Teams",
			getPickerItemsFromServerPlayers = true,
		},
		displayName = "UserIdOrName",
		description = "Accepts an @userName, displayName or userId and returns a HumanoidDescription.",
		defaultValue = false,
		--[[
		parse = newParse(function(self, stringToParse, callerUserId, targetUserId)
			local userId = Args.get("userId").parse(self, stringToParse, callerUserId, targetUserId)
			if not userId then
				return
			end
			local playerInServer = Players:GetPlayerByUserId(userId)
			if playerInServer and tonumber(callerUserId) ~= tonumber(userId) then
				local playerInServerDescription = main.modules.MorphUtil.getDescriptionFromPlayer(playerInServer)
				if playerInServerDescription then
					return playerInServerDescription
				end
			end
			local success, description = main.modules.MorphUtil.getDescriptionFromUserId(userId):await()
			if not success then
				return
			end
			return description
		end),
		verifyCanUse = function(self, callerUser, valueToParse, additional)
			if additional and tostring(additional.argNameOrAlias):lower() == "userdescriptionwithoutverification" then
				return true
			end
			local userId = Args.get("userId").parse(self, tostring(valueToParse), callerUser.userId)
			if not userId then
				return false, ("'%s' is an invalid UserId, DisplayName or @UserName!"):format(tostring(valueToParse))
			end
			local success, description = main.modules.MorphUtil.getDescriptionFromUserId(userId):await()
			if not success then
				return false, ("Failed to load description as userId '%s' is invalid!"):format(userId)
			end
			return true
		end,
		--]]
	}),

	["Fields"] = register({
		inputObject = {
			inputType = "InputFields",
			maxItems = 10,
		},
	}),

}
Args.items = items


-- TYPES
export type Argument = keyof<typeof(items)>
export type ArgumentDetail = {
	inputObject: InputObjects.InputConfig?,
	mustCreateAliasOf: string?,
	aliasOf: string?,
	description: string?,
	playerArg: boolean?,
	executeForEachPlayer: boolean?,
	parse: any?, --((...any) -> (...any))?,
	name: string?, -- Used for Arg.get(name)
	displayName: string?, -- The actual name shown within the UI, defaults to name
	defaultValue: any?,
	maxCharacters: number?,
}

return Args
