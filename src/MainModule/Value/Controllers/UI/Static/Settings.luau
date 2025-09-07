local HDAdminUI = script.Parent.Parent
local States = require(HDAdminUI.States)
local Fusion = require(HDAdminUI.Parent.Fusion)

export type Setting = {
	Name: string,
	Type: string,
	Options: { string }?,
	Value: Fusion.Value<any>,
	Default: any,
}
export type Category = {
	Name: string,
	Settings: { Setting },
}

local SETTINGS: { Category } = {
	{
		Name = "Theme",
		Settings = {
			{
				Name = "Dark mode",
				Type = "Boolean",
				Default = Fusion.peek(States.Settings.DarkMode),
				Value = States.Settings.DarkMode,
			},
			{
				Name = "Color",
				Type = "Color3",
				Default = Fusion.peek(States.Settings.ThemeStateMod),
				Value = States.Settings.ThemeStateMod,
			},
		},
	},
	{
		Name = "Commands",
		Settings = {
			{
				Name = "Prefix",
				Type = "String",
				Default = Fusion.peek(States.Settings.Prefix),
				Value = States.Settings.Prefix,
			},
		},
	},
	{
		Name = "Volume",
		Settings = {
			{
				Name = "Notice",
				Type = "Number",
				Default = Fusion.peek(States.Settings.NoticeVolume),
				Value = States.Settings.NoticeVolume,
			},
			{
				Name = "Error",
				Type = "Number",
				Default = Fusion.peek(States.Settings.ErrorVolume),
				Value = States.Settings.ErrorVolume,
			},
			{
				Name = "Alert",
				Type = "Number",
				Default = Fusion.peek(States.Settings.AlertVolume),
				Value = States.Settings.AlertVolume,
			},
		},
	},
}

return SETTINGS
