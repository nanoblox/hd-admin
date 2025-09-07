local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Fusion)
local ColorUtils = require(HDAdminUI.Parent.ColorUtils)

export type Props = OnyxUI.ButtonProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Color = OnyxUI.Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)
	local Padding = OnyxUI.Util.Fallback(Props.Padding, Scope:UDim(0, Theme.Padding["0.5"]))

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		ContentSize = Theme.TextSize["1"],
		Color = Color,
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},
		Stroke = {
			Color = Scope:Computed(function(Use)
				return ColorUtils.Lighten(Use(Color), Use(Theme.StrokeEmphasis.Regular))
			end),
			Gradient = {
				Enabled = false,
			},
		},
		Padding = {
			Top = Padding,
			Left = Padding,
			Right = Padding,
			Bottom = Padding,
		},
	}))
end
