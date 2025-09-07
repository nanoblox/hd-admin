local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local PageButton = require(script.Parent.Parent.PageButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		PageButton = PageButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},

		[Children] = {
			Scope:Frame {
				AutomaticSize = Enum.AutomaticSize.Y,
				List = {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = Scope:UDim(0, Theme.Spacing["1.5"]),
				},

				[Children] = {
					Scope:Icon {
						Image = CONFIG.Icons.LogoGlyph,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["3.75"]), Use(Theme.TextSize["3.75"]))
						end),
						ImageColor3 = Theme.Colors.NeutralContent.Main,
					},
					Scope:Text {
						Text = Scope:Computed(function(Use)
							return `{Use(States.Menu.Page)} is under development. Please check back later!`
						end),
						TextSize = Theme.TextSize["1.125"],
						TextColor3 = Theme.Colors.NeutralContent.Main,
						TextXAlignment = Enum.TextXAlignment.Center,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromScale(1, 0),
					},
				},
			},
		},
	}))
end
