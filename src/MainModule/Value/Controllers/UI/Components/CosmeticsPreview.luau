local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local Config = require(HDAdminUI.Config)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CosmeticButton = require(script.Parent.CosmeticButton)

export type Props = OnyxUI.BaseProps & {}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CosmeticButton = CosmeticButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "Cosmetics",
		AutomaticSize = Enum.AutomaticSize.Y,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Heading {
				Text = "Cosmetics",
				HeadingSize = 1.5,
			},
			Scope:Frame {
				Name = "CosmeticButtons",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Wraps = true,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(CONFIG.FeaturedCosmetics, function(Use, Scope, Id: string)
						return OnyxUI.Themer.Theme:is(Theme):during(function()
							return Scope:CosmeticButton {
								Id = Id,
								InfoType = Enum.InfoType.GamePass,
								Size = Scope:Computed(function(Use)
									return UDim2.fromScale(1 / 2, 0)
										+ UDim2.fromOffset(
											-(
													((Use(Theme.Spacing["0.5"])) + (Use(Theme.StrokeThickness["2"])))
													* (1 / 2)
												),
											0
										)
								end),
								AutomaticSize = Enum.AutomaticSize.Y,
							}
						end)
					end),
				},
			},
			Scope:Button {
				Content = { "Shop All" },
				ContentSize = Theme.TextSize["1"],
				SizeVariant = "ExtraLarge",

				OnActivate = function()
					NavigationStateMod:To("Cosmetics")
				end,
			},
		},
	}))
end
