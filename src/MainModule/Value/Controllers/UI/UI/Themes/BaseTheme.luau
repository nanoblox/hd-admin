local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)

return {
	Colors = {
		Primary = {
			Main = Color3.fromHex("#7066ff"),
		},
		Secondary = {
			Main = OnyxUI.Util.Colors.White,
		},
		Accent = {
			Main = OnyxUI.Util.Colors.White,
		},

		Neutral = {
			Main = OnyxUI.Util.Colors.Zinc["800"],
		},
		NeutralContent = {
			Main = OnyxUI.Util.Colors.Zinc["300"],
			Dark = OnyxUI.Util.Colors.Zinc["400"],
		},

		Base = {
			Main = OnyxUI.Util.Colors.Zinc["900"],
		},
		BaseContent = {
			Main = OnyxUI.Util.Colors.White,
		},

		Success = {
			Main = OnyxUI.Util.Colors.Green["500"],
		},
		Error = {
			Main = OnyxUI.Util.Colors.Red["500"],
		},
		Warning = {
			Main = OnyxUI.Util.Colors.Amber["400"],
		},
		Info = {
			Main = OnyxUI.Util.Colors.Cyan["400"],
		},
	},
	Font = {
		Body = "rbxasset://fonts/families/BuilderSans.json",
		Heading = "rbxasset://fonts/families/BuilderSans.json",
		Monospace = "rbxasset://fonts/families/BuilderMono.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.Bold,
		Heading = Enum.FontWeight.Heavy,
	},
	TextSize = {
		Base = 18,
	},
	CornerRadius = {
		Base = 6,
	},
	StrokeThickness = {
		Base = 1,
	},
	Spacing = {
		Base = 18,
	},
	Padding = {
		Base = 16,
	},
	Sizing = {
		Base = 16,
	},
	SpringSpeed = {
		Base = 60,
	},
	SpringDampening = {
		Base = 1.5,
	},
	-- Sound = {
	-- 	Hover = Scope:New("Sound") {
	-- 		SoundId = "rbxassetid://10066936758",
	-- 		Volume = 1,
	-- 	},
	-- 	Click = Scope:New("Sound") {
	-- 		SoundId = "rbxassetid://16480549841",
	-- 		Volume = 1,
	-- 	},
	-- 	Focus = Scope:New("Sound") {
	-- 		SoundId = "rbxassetid://16480549841",
	-- 		Volume = 1,
	-- 	},
	-- 	Switch = Scope:New("Sound") {
	-- 		SoundId = "rbxassetid://9119713951",
	-- 		Volume = 1,
	-- 	},
	-- },
	Emphasis = {
		Light = 0.1,
		Regular = 0.15,
		Strong = 0.5,
		Contrast = 1,
	},
}
