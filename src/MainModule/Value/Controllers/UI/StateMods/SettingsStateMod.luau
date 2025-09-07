local HDAdminUI = script.Parent.Parent
local States = require(HDAdminUI.States)
local Fusion = require(HDAdminUI.Parent.Fusion)
local DarkTheme = require(HDAdminUI.Themes.DarkTheme)
local LightTheme = require(HDAdminUI.Themes.LightTheme)

local Scope = Fusion.scoped(Fusion)

local SettingsStateMod = {}

function SettingsStateMod:UpdatePrimaryColor()
	local ThemeStateModValue = Fusion.peek(States.Settings.ThemeStateMod)
	local ThemeValue = Fusion.peek(States.Theme)

	ThemeValue.Colors.Primary.Main:set(ThemeStateModValue)
end

Scope:Observer(States.Settings.ThemeStateMod):onChange(function()
	SettingsStateMod:UpdatePrimaryColor()
end)

Scope:Observer(States.Settings.DarkMode):onChange(function()
	local DarkModeValue = Fusion.peek(States.Settings.DarkMode)

	if DarkModeValue then
		States.Theme:set(DarkTheme)
	else
		States.Theme:set(LightTheme)
	end

	SettingsStateMod:UpdatePrimaryColor()
end)

return SettingsStateMod
