local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Fusion)
local ColorUtils = require(HDAdminUI.Parent.ColorUtils)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = CustomButton.Props & {
	Title: Fusion.UsedAs<{ string }>?,
	Body: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Title = OnyxUI.Util.Fallback(Props.Title, { "Title" })
	local Body = OnyxUI.Util.Fallback(Props.Body, "Lorem ipsum doloreum")
	local Color = OnyxUI.Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)

	local Padding = Scope:UDim(0, Theme.Padding["1"])

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = Color,
		Padding = {
			Top = Padding,
			Left = Padding,
			Right = Padding,
			Bottom = Padding,
		},
		List = {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},
		Stroke = {
			Color = Scope:Computed(function(Use)
				return ColorUtils.Lighten(Use(Color), Use(Theme.Emphasis.Light))
			end),
		},

		[Children] = {
			Scope:Frame {
				Name = "Info",
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:IconText {
						Content = Title,
						FontFace = Scope:Computed(function(Use)
							return Font.new(Use(Theme.Font.Body), Use(Theme.FontWeight.Bold))
						end),
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
						},
					},
					Scope:Text {
						Text = Body,
						TextColor3 = Theme.Colors.NeutralContent.Main,
						ClipsDescendants = true,
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
						},
						Flex = {
							Mode = Enum.UIFlexMode.Fill,
						},
					},
				},
			},
		},
	}))
end
