local HDAdmin = script.Parent.Parent
local Fusion = require(HDAdmin.Parent.Fusion)
local OnyxUI = require(HDAdmin.Parent.OnyxUI)
local Config = require(HDAdmin.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local DonationButton = require(script.Parent.DonationButton)

export type Props = OnyxUI.BaseProps & {}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		DonationButton = DonationButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		AutomaticSize = Enum.AutomaticSize.Y,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Heading {
				Text = "Donate",
				HeadingSize = 1.5,
			},
			Scope:Frame {
				Name = "DonationButtons",
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					FillDirection = Enum.FillDirection.Horizontal,
					Wraps = true,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForPairs(
						CONFIG.DonationProducts,
						function(Use, Scope, Id: string, Donation: typeof(CONFIG.DonationProducts["10"]))
							return Id,
								OnyxUI.Themer.Theme:is(Theme):during(function()
									return Scope:DonationButton {
										Id = Id,
										AutomaticSize = Enum.AutomaticSize.Y,
										LayoutOrder = Donation.Amount,
										Size = Scope:Computed(function(Use)
											return UDim2.fromScale(0.5, 0)
												+ UDim2.fromOffset(-Use(Theme.Spacing["0.5"]), 0)
										end),
									}
								end)
						end
					),
				},
			},
		},
	}))
end
