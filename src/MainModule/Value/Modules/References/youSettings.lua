--!strict

-- These are settings which can be changed by the local user, and only change
-- for that particular user.
-- To retrieve data do:

--[[
local DATA_KEY = "YouSettings"
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local clientUser = require(modules.References.clientUser)
local perm = clientUser.perm
local settingPath = {DATA_KEY, "Sound", "Volume", "Music"}
perm:listen(settingPath, function(newValue)
	print("musicVolume (CHANGED):", newValue)
end)
print("musicVolume (1) =", perm:get(settingPath))
print("musicVolume (2) =", perm:fetchAsync(settingPath))
local _, youSettings = perm:fetchAsync(DATA_KEY)
print("musicVolume (3) =", perm:get(settingPath))
print("youSettings =", youSettings)
--]]


-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local InputObjects = require(modules.Parser.InputObjects)
type InputType = InputObjects.InputType
type InputConfig = InputObjects.InputConfig


-- CONFIG
local DATA_KEY = "YouSettings"
local SOUND_INPUT: InputConfig = {
	inputType = "NumberSlider",
	minValue = 0,
	maxValue = 2,
	stepAmount = 0.1,
}
local SOUND_VERIFIER = function(value: number)
	if typeof(value) ~= "number" then
		return 1
	end
	return math.clamp(value, 0, 2)
end


-- SETTINGS
return {

	["Theme"] = {
		{
			title = "Dark Mode",
			description = "This is an unfinished description to describe this setting",
			inputType = "Toggle" :: InputType,
			settingPath = {DATA_KEY, "Theme", "DarkMode"},
			verifier = function(value)
				return value
			end,
		},
		{
			title = "Primary Color",
			description = "This is an unfinished description to describe this setting",
			inputType = "ColorPicker" :: InputType,
			settingPath = {DATA_KEY, "Theme", "PrimaryColor"},
			verifier = function(value)
				return value
			end,
		},
	},

	["Command"] = {
		{
			title = "Prefix",
			description = "This is an unfinished description to describe this setting",
			inputType = "TextInput" :: InputType,
			settingPath = {DATA_KEY, "Prefix"},
			verifier = function(value)
				return value
			end,
		},
	},

	["Sound"] = {
		{
			title = "Music Volume",
			description = "Volume of music-related sounds (such as from ;music)",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Volume", "Music"},
			verifier = SOUND_VERIFIER,
		},
		{
			title = "Music Pitch",
			description = "Pitch of music-related sounds (such as from ;music)",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Pitch", "Music"},
			verifier = SOUND_VERIFIER,
		},

		{
			title = "Command Volume",
			description = "Volume of sounds played from commands",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Volume", "Command"},
			verifier = SOUND_VERIFIER,
		},
		{
			title = "Command Pitch",
			description = "Pitch of sounds played from commands",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Pitch", "Command"},
			verifier = SOUND_VERIFIER,
		},

		{
			title = "Interface Volume",
			description = "Volume of UI-based sounds (such as clicking, etc)",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Volume", "Interface"},
			verifier = SOUND_VERIFIER,
		},
		{
			title = "Interface Pitch",
			description = "Pitch of UI-based sounds (such as clicking, etc)",
			inputType = "NumberSlider" :: InputType,
			inputObject = SOUND_INPUT,
			settingPath = {DATA_KEY, "Sound", "Pitch", "Interface"},
			verifier = SOUND_VERIFIER,
		},
	},

}