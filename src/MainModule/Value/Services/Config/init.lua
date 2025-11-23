-- CONFIG
local SETTINGS_TO_EXCLUDE_FROM_CLIENT: {Setting} = {
	-- By default everything is fetchable on the client unless specified here
}
local ACCESSIBLE = {
	["Args"] = true,
}


-- LOCAL
local Config = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local config = modules.Parent.Services.Config
local User = require(modules.Objects.User)
local configSettings = require(config.Settings)


-- TYPES
export type PlayerSearch = configSettings.PlayerSearch
export type SettingType = "Player" | "System"
export type Setting = keyof<typeof(configSettings.PlayerSettings)> | keyof<typeof(configSettings.SystemSettings)>


-- FUNCTIONS
function Config.isAccessible(moduleName: string): boolean
	-- Returns whether the specified module is accessible directly under Config on both client and server
	return ACCESSIBLE[moduleName] == true
end

function Config.getAccessible()
	return ACCESSIBLE
end

function Config.getSetting(settingName: Setting, optionalUser: User.Class?): any
	-- If a user is specified, it aims to return their setting saved under their
	-- 'YouSettings' perm. If that valid is nil, or no user is specified, then
	-- it returns the value from 'GameSettings' within everyone.
	Config.updateSettings()
	local gameSettings = User.everyone:get("GameSettings")
	local youSettings = if typeof(optionalUser) == "table" and optionalUser.isLoaded then optionalUser.perm:get("YouSettings") else nil
	local settingsToUse = youSettings or gameSettings
	local value = settingsToUse[settingName]
	print("gameSettings, youSettings, value =", gameSettings, youSettings, value)
	if youSettings and value == nil then
		value = gameSettings[settingName]
	end
	return value
end

function Config.updateSettings()
	-- In the future this will act as a way to update settings from datastores
	-- For now, all this does it set the game dev's loader settings into the
	-- key "GameSettings" within the everyone state table. It's important to note
	-- that Settings within 'GameSettings' include *both* PlayerSettings and SystemSettings,
	-- BUT do not have these as nested tables. Instead, each setting is at the top-level
	-- of the "GameSettings" table. E.g. GameSettings.Prefix, GameSettings.PlayerIdentifier, etc
	-- (This is safe to yield, and in the future will)
	local gameSettings = {}
	for settingType, settingTable in configSettings do
		for settingName, value in settingTable do
			if gameSettings[settingName] then
				error(`HD Admin: Duplicate setting '{settingName}' found in Settings. You must re-name then try again.`)
			end
			gameSettings[settingName] = value
		end
	end
	print("gameSettings =", gameSettings)
	User.everyone:set("GameSettings", gameSettings)
end


-- SETUP
-- These set restrictions on what the client can see, and which clients
local getStateVerifier = require(modules.VerifyUtil.getStateVerifier)
User.everyone:verify(getStateVerifier(
	"GameSettings",
	"Exclude",
	SETTINGS_TO_EXCLUDE_FROM_CLIENT
))

-- This is essential to ensure data fetched via User.everyone is accurate
local State = require(modules.Objects.State)
State.verifyFirstFetch("GameSettings", Config.updateSettings)


return Config