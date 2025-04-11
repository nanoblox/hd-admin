--[[

To do:
	- Consider make inputObject return a function WHICH returns a table, so that
	  callerUserId specific considerations can be made (such as limits)
	  (but first consdier how this works with global networking)
	  
--]]


--!strict
-- LOCAL
local Args = {}
local Players = game:GetService("Players")
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local InputObjects = require(modules.UI.InputObjects)
local items = {}


-- LOCAL FUNCTIONS
local function register(item: ArgumentDetail): ArgumentDetail
	return item :: ArgumentDetail -- We do this to support type checking within the table
end


-- FUNCTIONS
function Args.get(qualifierName: Argument): ArgumentDetail?
	local item = Args.items[qualifierName]
	if not item then
		return nil
	end
	if not item.name then
		item.name = qualifierName :: any
	end
	local toBecomeName = item.mustBecomeAliasOf
	if toBecomeName then
		local qualifierToBecome = Args.items[toBecomeName]
		if not qualifierToBecome then
			error(`Args: {qualifierName} can not become alias because {toBecomeName} is not a valid qualifier`)
		end
		qualifierToBecome = qualifierToBecome :: any
		for k,v in qualifierToBecome do
			if not item[k] then
				item[k] = v
			end
		end
		item.mustBecomeAliasOf = nil :: any
		item.aliasOf = toBecomeName
	end
	return item :: ArgumentDetail
end

function Args.getAll()
	-- We call .get to ensure all aliases are registered and setup correctly
	for qualifierName, _ in Args.items do
		Args.get(qualifierName)
	end
	local items = Args.items :: {[Argument]: ArgumentDetail}
	return items
end

function Args.becomeAliasOf(qualifierName: Argument, initialTable: any?): ArgumentDetail
	-- We don't actually create a mirror table here as the data of items will have
	-- not yet gone into memory. Instead, we record the table as an alias, then
	-- set it's data once .get is called or 
	task.defer(function()
		-- This servers as a warning as opposed to an actual error
		if not Args.items[qualifierName] then
			error(`Args: {qualifierName} is not a valid qualifier`)
		end
	end)
	if typeof(initialTable) ~= "table" then
		initialTable = {}
	end
	initialTable.mustBecomeAliasOf = qualifierName
	return initialTable
end


-- PUBLIC
Args.items = {

	["Player"] = register({
		-- Accepts qualifiers ("me", "all", "others") or players within game.Players
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others'), calls the command *for each player*, and returns a single Player instance.",
		playerArg = true,
		executeForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId, additional)
			--[[
			local defaultToMe = qualifiers == nil or main.modules.TableUtil.isQualifiersEmpty(qualifiers)
			local ignoreDefault = (additional and additional.ignoreDefault)
			if defaultToMe and not ignoreDefault then
				local players = {}
				local callerPlayer = Players:GetPlayerByUserId(callerUserId)
				if callerPlayer then
					table.insert(players, callerPlayer)
				end
				return players
			end
			local targetsDict = {}
			for qualifierName, qualifierArgs in pairs(qualifiers or {}) do
				if qualifierName == "" then
					continue
				end
				local Qualifiers = main.modules.Parser.Qualifiers
				local qualifierDetail = Qualifiers.get(qualifierName)
				local targets
				if not qualifierDetail then
					qualifierDetail = Qualifiers.get("user")
					targets = qualifierDetail.getTargets(callerUserId, qualifierName)
				else
					targets = qualifierDetail.getTargets(callerUserId, unpack(qualifierArgs))
				end
				for _, plr in pairs(targets) do
					targetsDict[plr] = true
				end
			end
			local players = {}
			for plr, _ in pairs(targetsDict) do
				table.insert(players, plr)
			end
			return players
			--]]
		end,
	}),

	["Players"] = register({
		-- Accepts qualifiers ("me", "all", "others") or players within game.Players
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
			--[[
			if main.modules.TableUtil.isQualifiersEmpty(qualifiers) then
				return nil
			end
			local players = main.modules.Parser.Args.get("player"):parse(qualifiers, callerUserId, {ignoreDefault = true})
			return players
			--]]
		end,
	}),

	["TargetPlayer"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
			onlySelectOne = true,
		},
		description = "Accepts qualifiers (e.g. 'raza', '@ForeverHD', 'others' from ';paint raza,@ForeverHD,others') and returns a single Player instance (or false).",
		defaultValue = false,
		playerArg = true,
		executeForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId)
			--[[
			local players = main.modules.Parser.Args.get("player"):parse(qualifiers, callerUserId, {ignoreDefault = true})
			return players[1]
			]]
		end,
	}),

	["OptionalPlayer"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Players",
			getPickerItemsFromServerPlayers = true,
		},
		description = "Hides the players argument for general use and only displays it within the preview menu.",
		playerArg = true,
		hidden = true,
		executeForEachPlayer = true,
		parse = function(self, qualifiers, callerUserId)
			--[[
			local defaultToAll = qualifiers == nil or main.modules.TableUtil.isEmpty(qualifiers)
			if defaultToAll then
				return Players:GetPlayers()
			end
			return main.modules.Parser.Args.get("player"):parse(qualifiers, callerUserId)
			]]
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
			--[[
			local players = main.modules.Parser.Args.get("optionalplayer"):parse(qualifiers, callerUserId)
			return players
			--]]
		end,
	}),

	["AnyPlayer"] = register({
		-- Accepts qualifiers ("me", "all", "others") or players within game.Players
		-- Accepts an Integer OR String OR Qualifier ("me", "all", "others")
		-- Upon FocusLost of the box, it will search for that user (by UserId or Name)
		-- of the corresponding account. If present, it displays the profile image, userId
		-- and username in or below the box. If an invalid user (such as a banned account)
		-- or too higher integer, then display a Red outline requiring the box to be re-done
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Server & Offline Players",
			getPickerItemsFromAnyPlayer = true,
		},
		inputOptions = {},
		displayName = "userNameOrId",
		description = "Accepts an @userName, displayName, userId or qualifier and returns a userId.",
		defaultValue = false,
		parse = function(self, stringToParse, callerUserId)
			--[[
			local callerUser = main.modules.PlayerStore:getUserByUserId(callerUserId)
			local playersInServer = Args.dictionary.player:parse({[stringToParse] = {}}, callerUserId) --main.modules.Parser.getPlayersFromString(stringToParse, callerUser)
			local player = playersInServer[1]
			if player then
				return player.UserId
			end
			local userId = tonumber(stringToParse)
			if userId then
				return userId
			end
			local approved, username = main.modules.Parser.verifyAndParseUsername(callerUser, stringToParse)
			local success, finalUserId
			if approved then
				success, finalUserId = main.modules.PlayerUtil.getUserIdFromName(username):await()
			end
			if success then
				return finalUserId
			end
			--]]
		end,
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
		parse = function(self, textToFilter, callerUserId, playerUserId)
			--[[
			local _, value = main.modules.ChatUtil.filterText(callerUserId, playerUserId, textToFilter):await()
			return value
			--]]
		end,
	}),
	
	["SingleText"] = register({
		inputObject = {
			inputType = "TextInput",
			filterText = true,
			preventWhitespaces = true,
		},
		description = "Accepts a non-endless string (i.e. a string with no whitespace gaps) and filters it based upon the caller and target.",
		defaultValue = "",
		endlessArg = false,
		parse = function(...)
			--return Args.get("text").parse(...)
		end,
	}),

	["UnfilteredText"] = register({
		inputObject = {
			inputType = "TextInput",
			filterText = false,
		},
		description = "Accepts a string and returns it unfiltered.",
		defaultValue = "",
		endlessArg = true,
		parse = function(self, stringToParse)
			return stringToParse
		end,
	}),

	["Code"] = Args.becomeAliasOf("UnfilteredText"),

	["Number"] = register({
		inputObject = {
			inputType = "NumberInput",
		},
		description = "Accepts a number string and returns a Number",
		defaultValue = 0,
		parse = function(self, stringToParse)
			return tonumber(stringToParse)
		end,
	}),

	["Integer"] = Args.becomeAliasOf("Number", register({
		-- Accepts a number value (but only whole numbers)
		-- Consider the same as Number
		inputObject = {
			inputType = "NumberInput",
			stepAmount = 1,
		},
	})),

	["Scale"] = Args.becomeAliasOf("Number", register({
		inputObject = {
			inputType = "NumberInput",
			minValue = 0,
			maxValue = 5,
		},
		description = "Accepts a number and returns a number which is considerate of scale limits.",
		defaultValue = 1,
		parse = function(self, stringToParse)
			--local scaleValue = tonumber(stringToParse)
			--return scaleValue
		end,
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
	})),

	["Speed"] = Args.becomeAliasOf("Number", register({
		inputObject = {
			inputType = "NumberSlider",
			minValue = 0,
			maxValue = 100,
			stepAmount = 1
		},
		defaultValue = 1,
	})),

	["AnimationSpeed"] = Args.becomeAliasOf("Number", register({
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
		parse = function(self, stringToParse): number?
			local number = tonumber(stringToParse)
			if number then
				return number % 360
			end
			return nil
		end,
		--]]
	}),
	
	["Duration"] = register({
		-- See ban panel time section, 1h, 4m, etc
		inputObject = {
			inputType = "TimeSelector",
		},
		description = "Accepts a timestring (such as '5s7d8h') and returns the integer equivalent in seconds. Timestring letters are: seconds(s), minutes(m), hours(h), days(d), weeks(w), months(o) and years(y).",
		defaultValue = 0,
		parse = function(self, stringToParse)
			--return main.modules.DataUtil.convertTimeStringToSeconds(tostring(stringToParse))
		end,
	}),

	["Color"] = register({
		-- Accepts a Color3 value (generated from color wheel, or presets)
		inputObject = {
			inputType = "ColorPicker",
		},
		description = "Accepts a color name (such as 'red'), a hex code (such as '#FF0000') or an RGB capsule (such as '[255,0,0]') and returns a Color3.",
		defaultValue = false,
		parse = function(self, stringToParse)
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
		end,
	}),

	["Colour"] = Args.becomeAliasOf("Color"),

	["Gradient"] = Args.becomeAliasOf("Color"),

	["OptionalColor"] = Args.becomeAliasOf("Color", register({
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
		parse = function(self, stringToParse)
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
		end,
	}),

	["Toggle"] = Args.becomeAliasOf("Bool"),

	["Leaderstat"] = register({
		-- Accepts the names of stats within the player's leaderstats:
		-- https://create.roblox.com/docs/players/leaderboards
		-- Leaderstats may not exist within the player, so must be checked for
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Leaderstats",
			pickerItems = function()
				-- Return array of leaderstat names from player's leaderstats
				return {}
			end,
		},
		description = "Accepts a valid stat name and returns the stat (defined in Server/Modules/StatHandler). This requires the 'player' arg as the first argument to work.",
		defaultValue = false,
		parse = function(self, stringToParse, _, playerUserId)
			--[[
			local targetPlayer = Players:GetPlayerByUserId(playerUserId)
			local stat = (targetPlayer and main.modules.StatHandler.get(targetPlayer, stringToParse))
			return stat
			--]]
		end,
	}),

	["Team"] = register({
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Teams",
			pickerItems = function()
				-- Return array of team names with game.Teams
				return {}
			end,
		},
		displayName = "TeamName",
		description = "Accepts a valid team name and returns the team instance.",
		defaultValue = false,
		parse = function(self, stringToParse)
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
		end,
	}),

	["Material"] = register({
		-- Accepts the names of materials from Enum.Material 
		inputObject = {
			inputType = "ItemSelector",
			pickerName = "Materials",
			pickerItems = function()
				-- Return array of all possible material enums
				return {}
			end,
		},
		description = "Accepts a valid material and returns a Material enum.",
		defaultValue = false,
		parse = function(self, stringToParse)
			--[[
			local enumItem = materialEnumNamesLowercase[stringToParse:lower()]
			if enumItem then
				return enumItem
			end
			--]]
		end,
	}),

	["Gear"] = register({
		-- Accepts the names of gear centralised in an array
		-- For now, just make up this array
		inputObject = {
			inputType = "NumberInput",
		},
		displayName = "GearId",
		description = "Accepts a gearId (aka a CatalogId) and returns the Tool instance if valid. Do not use the returned Tool instance, clone it instead.",
		defaultValue = false,
		--[[
		parse = function(self, stringToParse)
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
		end,
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
		parse = function(self, stringToParse, _, playerUserId)
			local humanoid = main.modules.PlayerUtil.getHumanoid(playerUserId)
			local success, description = main.modules.MorphUtil.getDescriptionFromBundleId(stringToParse, humanoid):await()
			if not success then
				return
			end
			return description
		end,
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
		parse = function(self, stringToParse, callerUserId, playerUserId)
			local userId = Args.get("userId").parse(self, stringToParse, callerUserId, playerUserId)
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
		end,
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

	["Options"] = register({
		-- Accepts an array of strings
		-- For example, the ;vote command has the ability to +Create and -Delete
		-- option boxes, then input a string into these boxes
		inputObject = {
			inputType = "TextOptions",
			maxItems = 10,
		},
	}),

} :: {[string]: ArgumentDetail}


-- TYPES
export type Argument = keyof<typeof(Args.items)>
export type Argument2 = keyof<typeof(items)>
export type ArgumentDetail = {
	inputObject: InputObjects.InputConfig?,
	mustBecomeAliasOf: string?,
	aliasOf: string?,
	description: string?,
	playerArg: boolean?,
	executeForEachPlayer: boolean?,
	parse: ((...any) -> (...any))?,
}


return Args