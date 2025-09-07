local HDAdminUI = script.Parent.Parent
local Sift = require(HDAdminUI.Parent.Sift)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local BaseTheme = require(script.Parent.BaseTheme)
local Fusion = require(HDAdminUI.Parent.Fusion)

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
