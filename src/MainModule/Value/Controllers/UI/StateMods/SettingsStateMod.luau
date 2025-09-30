local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local States = require(UI.States)
local Fusion = require(Packages.Fusion)
local DarkTheme = require(UI.Themes.DarkTheme)
local LightTheme = require(UI.Themes.LightTheme)

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
