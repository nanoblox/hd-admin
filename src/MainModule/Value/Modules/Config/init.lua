-- LOCAL
local Config = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local config = modules.Config
local User = require(modules.Objects.User)
local configSettings = require(config.Settings)


-- TYPES
export type PlayerSearch = configSettings.PlayerSearch
export type SettingType = "Player" | "System"
export type Setting = keyof<typeof(configSettings.PlayerSettings)> | keyof<typeof(configSettings.SystemSettings)>


-- FUNCTIONS
function Config.getSetting(settingName: Setting, optionalUser: User.Class?, forcedSettingType: SettingType?): any
	-- If a user is specified, it returns the setting value of that users, otherwise
	-- the default value (under the user's Config Settings) is returned
	-- 'Player' Settings are checked first, then 'System'
	if forcedSettingType == "System" then
		return configSettings.SystemSettings[settingName]
	end
	if typeof(optionalUser) == "table" and optionalUser.isLoaded == true then
		local value = optionalUser.perm:get("PlayerSettings", settingName)
		if value ~= nil or forcedSettingType == "Player" then
			return value
		end
	end
	local value = configSettings.PlayerSettings[settingName]
	if value ~= nil or forcedSettingType == "Player" then
		return value
	end
	return configSettings.SystemSettings[settingName]
end


return Config