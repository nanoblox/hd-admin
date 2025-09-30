local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)
local Signals = require(UI.Signals)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CosmeticButton = require(script.Parent.Parent.CosmeticButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CosmeticButton = CosmeticButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Scroller {
				Name = "CosmeticButtons",
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Wraps = true,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForPairs(
						CONFIG.Cosmetics,
						function(Use, Scope, Id: string, Cosmetic: typeof(CONFIG.Cosmetics[1]))
							return Id,
								OnyxUI.Themer.Theme:is(Theme):during(function()
									return Scope:CosmeticButton {
										Id = Id,
										InfoType = Enum.InfoType.GamePass,
										Size = Scope:Computed(function(Use)
											return UDim2.fromScale(1 / 2, 0)
												+ UDim2.fromOffset(
													-(
															(
																(Use(Theme.Spacing["0.5"]))
																+ (Use(Theme.StrokeThickness["2"]))
															) * (1 / 2)
														),
													0
												)
										end),
										AutomaticSize = Enum.AutomaticSize.Y,
									}
								end)
						end
					),
				},
			},
			Scope:Button {
				Name = "PurchaseButton",
				Content = Scope:Computed(function(Use)
					local WornCosmeticsValue = Use(States.Perks.Cosmetics.Worn)

					return { `Buy {#WornCosmeticsValue}` }
				end),
				Color = Theme.Colors.Primary.Main,
				SizeVariant = "ExtraLarge",
				ContentSize = Theme.TextSize["1"],
				Visible = Scope:Computed(function(Use)
					return #Use(States.Perks.Cosmetics.Worn) > 0
				end),

				OnActivate = function()
					local WornCosmetics = Fusion.peek(States.Perks.Cosmetics.Worn)

					if #WornCosmetics >= 1 then
						Signals.CosmeticsCheckedOut:Fire(WornCosmetics)
					end
				end,
			},
		},
	}))
end
