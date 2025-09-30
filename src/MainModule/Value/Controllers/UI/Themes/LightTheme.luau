local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local Sift = require(Packages.Sift)
local OnyxUI = require(Packages.OnyxUI)
local BaseTheme = require(script.Parent.BaseTheme)
local Fusion = require(Packages.Fusion)

local Scope = Fusion.scoped(Fusion)

local LightTheme = OnyxUI.Themer.NewTheme(
	Scope,
	Sift.Dictionary.mergeDeep(BaseTheme, {
		Colors = {
			Neutral = {
				Main = OnyxUI.Util.Colors.Zinc["200"],
			},
			NeutralContent = {
				Main = OnyxUI.Util.Colors.Zinc["800"],
				Dark = OnyxUI.Util.Colors.Zinc["900"],
			},

			Base = {
				Main = OnyxUI.Util.Colors.White,
			},
			BaseContent = {
				Main = OnyxUI.Util.Colors.Black,
			},
		},
	})
)

return LightTheme
