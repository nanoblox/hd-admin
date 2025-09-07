local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Navigation = require(HDAdminUI.Static.Navigation)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)
local Signals = require(HDAdminUI.Signals)

local Children = Fusion.Children

local PageButton = require(script.Parent.Parent.PageButton)
local CustomButton = require(script.Parent.Parent.CustomButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		PageButton = PageButton,
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.fromOffset(0, 0),
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},

		[Children] = {
			Scope:Frame {
				Name = "Pages",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					Wraps = true,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},

				[Children] = {
					Scope:ForValues(Navigation.Children, function(Use, Scope, NavPage)
						return OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
							return Scope:PageButton {
								Id = NavPage.Page.Id,
								Size = Scope:Computed(function(Use)
									return UDim2.fromScale(0.5, 0) + UDim2.fromOffset(-Use(Theme.Spacing["0.5"]), 0)
								end),
								AutomaticSize = Enum.AutomaticSize.Y,
							}
						end)
					end),
				},
			},
		},
	}))
end
