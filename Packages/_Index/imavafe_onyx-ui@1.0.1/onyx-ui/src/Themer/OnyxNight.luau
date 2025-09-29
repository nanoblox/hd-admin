local OnyxUI = script.Parent.Parent
local Util = require(OnyxUI.Util)
local NewTheme = require(script.Parent.NewTheme)
local Fusion = require(OnyxUI.Parent.Fusion)

local Scope = Fusion.scoped(Fusion)

local OnyxNight = NewTheme(Scope, {
	Colors = {
		Primary = {
			Main = Util.Colors.Violet["500"],
		},
		Secondary = {
			Main = Util.Colors.White,
		},
		Accent = {
			Main = Util.Colors.White,
		},

		Neutral = {
			Main = Util.Colors.Stone["800"],
		},
		NeutralContent = {
			Main = Util.Colors.Stone["300"],
		},

		Base = {
			Main = Util.Colors.Stone["900"],
		},
		BaseContent = {
			Main = Util.Colors.White,
		},

		Success = {
			Main = Util.Colors.Green["500"],
		},
		Error = {
			Main = Util.Colors.Red["500"],
		},
		Warning = {
			Main = Util.Colors.Amber["500"],
		},
		Info = {
			Main = Util.Colors.Cyan["400"],
		},
	},
	Font = {
		Body = "rbxasset://fonts/families/Montserrat.json",
		Heading = "rbxasset://fonts/families/Montserrat.json",
		Monospace = "rbxasset://fonts/families/Montserrat.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.Bold,
		Heading = Enum.FontWeight.Bold,
	},
	TextSize = {
		Base = 19,
	},
	CornerRadius = {
		Base = 8,
	},
	StrokeThickness = {
		Base = 1,
	},
	StrokeEmphasis = {
		Regular = 0.2,
	},
	Spacing = {
		Base = 22,
	},
	Sizing = {
		Base = 22,
	},
	Padding = {
		Base = 24,
	},
	SpringSpeed = {
		Base = 50,
	},
	SpringDampening = {
		Base = 1,
	},
	Sound = {},
	Emphasis = {},
})

return OnyxNight
