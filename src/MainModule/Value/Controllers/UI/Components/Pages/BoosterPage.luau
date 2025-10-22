local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)
local Callbacks = require(UI.Callbacks)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local PageButton = require(script.Parent.Parent.PageButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		PageButton = PageButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			VerticalFlex = Enum.UIFlexAlignment.SpaceBetween,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		},

		[Children] = {
			Scope:IconText {
				Content = { CONFIG.Icons.LogoGlyph, "Commands" },
				ContentSize = Theme.TextSize["1.5"],
				ContentFontFace = Scope:Font(Theme.Font.Heading, Theme.FontWeight.Heading),
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},
			},
			Scope:Card {
				Name = "SellingPoints",
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:ForValues({
						{
							Icon = CONFIG.Icons.TerminalFill,
							Text = "Unlock 50+ exclusive commands",
						},
						{
							Icon = CONFIG.Icons.GlobeFill,
							Text = "Use in thousands of games across Roblox",
						},
						{
							Icon = CONFIG.Icons.HeartFill,
							Text = "Support the development of this game and HD Admin",
						},
					}, function(Use, Scope, Point)
						return Scope:Frame {
							List = {
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},

							[Children] = {
								Scope:Icon {
									Image = Point.Icon,
									Size = Scope:UDim2Offset(Theme.TextSize["1.5"], Theme.TextSize["1.5"]),
								},
								Scope:Text {
									Text = Point.Text,
									AutomaticSize = Enum.AutomaticSize.XY,
									Flex = {
										Mode = Enum.UIFlexMode.Fill,
									},
								},
							},
						}
					end),
				},
			},
			Scope:Card {
				Name = "Buttons",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
				},

				[Children] = {
					Scope:Button {
						Name = "BuyButton",
						Content = { "Unlock" },
						ContentSize = Theme.TextSize["1"],
						SizeVariant = "ExtraLarge",
						Color = Theme.Colors.Primary.Main,

						OnActivate = function()
							Callbacks.BoosterPurchaseInitiated()
						end,
					},
					Scope:Button {
						Name = "ViewButton",
						Content = { "View" },
						ContentSize = Theme.TextSize["1"],
						SizeVariant = "ExtraLarge",

						OnActivate = function()
							PanelsStateMod.ToPage(Panel, "Commands")
						end,
					},
				},
			},
		},
	}))
end
