local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)
local States = require(UI.States)
local Sift = require(Packages.Sift)
local UserInformant = require(UI.Utils.UserInformant)
local CosmeticsStateMod = require(UI.StateMods.CosmeticsStateMod)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CreditGroup = require(script.Parent.Parent.CreditGroup)
local CreditBadge = require(script.Parent.Parent.CreditBadge)
local Category = require(script.Parent.Parent.Category)
local ContributorCredits = require(script.Parent.Parent.ContributorCredits)
local LibraryCredits = require(script.Parent.Parent.LibraryCredits)
local DonationLeaderboard = require(script.Parent.Parent.DonationLeaderboard)
local CosmeticsPreview = require(script.Parent.Parent.CosmeticsPreview)
local DonationButtons = require(script.Parent.Parent.DonationButtons)

export type Props = OnyxUI.FrameProps & {
	Open: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		CreditGroup = CreditGroup,
		CreditBadge = CreditBadge,
		Category = Category,
		ContributorCredits = ContributorCredits,
		LibraryCredits = LibraryCredits,
		DonationLeaderboard = DonationLeaderboard,
		CosmeticsPreview = CosmeticsPreview,
		DonationButtons = DonationButtons,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Open = OnyxUI.Util.Fallback(Props.Open, false)

	local SelectedCredit = Panel.PagesData.About.SelectedCredit
	local SelectedCreditSafe = Scope:Computed(function(Use)
		return Sift.Dictionary.merge({
			Name = "SelectedLibrary",
			Image = CONFIG.Icons.LogoGlyphOutline,
			Link = "https://devforum.roblox.com",
		}, Use(SelectedCredit))
	end)
	local Outdated = Scope:Computed(function(Use)
		return CONFIG.Version.Current ~= CONFIG.Version.Latest
	end)
	local SelectedCreditLink = Scope:Value("")

	Scope:Observer(SelectedCredit):onChange(function()
		SelectedCreditLink:set(Fusion.peek(SelectedCreditSafe).Link)
	end)

	local function UnequipCosmetics()
		for Id, _ in CONFIG.Cosmetics do
			CosmeticsStateMod:SetEquipped(Id, false)
		end
	end

	Scope:Observer(Open):onChange(function()
		UnequipCosmetics()
	end)
	Scope:Observer(Panel.Open):onChange(function()
		UnequipCosmetics()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Scroller {
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["1.5"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Frame {
						Name = "Updates",
						List = {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						},

						[Children] = {
							Scope:Icon {
								Image = CONFIG.Icons.LogoGlyph,
								ImageColor3 = Theme.Colors.BaseContent.Main,
								Size = Scope:Computed(function(Use)
									return UDim2.fromOffset(Use(Theme.TextSize["3.75"]), Use(Theme.TextSize["3.75"]))
								end),
							},
							Scope:Frame {
								List = {
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
								},

								[Children] = {
									Scope:Text {
										Text = "HD Admin",
										TextSize = Theme.TextSize["1.5"],
										FontFace = Scope:Computed(function(Use)
											return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
										end),
									},
									Scope:CreditBadge {
										Label = Scope:Computed(function(Use)
											return `{CONFIG.Version.Current}{Use(Outdated) and " - Outdated" or ""}`
										end),
										Image = CONFIG.Icons.LogoGlyphOutline,
										ImageShown = false,
										Color = Scope:Computed(function(Use)
											if Use(Outdated) then
												return Use(Theme.Colors.Warning.Main)
											else
												return Use(Theme.Colors.Neutral.Main)
											end
										end),
										ContentFontFace = Scope:Computed(function(Use)
											return Font.new(Use(Theme.Font.Monospace), Use(Theme.FontWeight.Body))
										end),
										Link = CONFIG.Credits.Libraries[1].Link,
									},
								},
							},
							Scope:Frame {
								Name = "UpdatesLink",
								List = {
									FillDirection = Enum.FillDirection.Horizontal,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									Padding = Scope:UDim(0, Theme.Spacing["0"]),
								},
								Stroke = {
									Color = Theme.Colors.Neutral.Light,
								},
								Corner = {
									Radius = Scope:UDim(0, Theme.CornerRadius.Full),
								},
								Padding = {
									All = Scope:UDim(0, Theme.Padding["0"]),
									Left = Scope:UDim(0, Theme.Padding["0.5"]),
									Right = Scope:UDim(0, Theme.Padding["0.5"]),
								},

								[Children] = {
									Scope:Icon {
										Image = CONFIG.Icons.NewsOutline,
										ImageColor3 = Theme.Colors.NeutralContent.Dark,
										Size = Scope:UDim2Offset(Theme.TextSize["1.25"], Theme.TextSize["1.25"]),
									},
									Scope:TextInput {
										Text = "https://devforum.roblox.com/",
										TextEditable = false,
										Flex = {
											Mode = Enum.UIFlexMode.Fill,
										},
										Stroke = {
											Enabled = false,
										},
									},
								},
							},
						},
					},
					Scope:Divider {},
					Scope:CosmeticsPreview {},
					Scope:Divider {},
					Scope:ContributorCredits {},
					Scope:LibraryCredits {},
					Scope:Divider {},
					Scope:DonationButtons {},
					Scope:DonationLeaderboard {
						AutomaticSize = Enum.AutomaticSize.Y,
					},
					Scope:Divider {},
					Scope:Frame {
						List = {
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
						},

						[Children] = {
							Scope:IconText {
								Content = { "rbxassetid://135468847489534" },
								ContentSize = Theme.TextSize["1.5"],
								ContentColor = Theme.Colors.NeutralContent.Dark,
								List = {
									Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
								},
							},
						},
					},
					Scope:Divider {},
					Scope:Button {
						Content = { "Booster" },

						OnActivate = function()
							local BoosterPanel = PanelsStateMod.New(Scope, Panel)
							PanelsStateMod.ToPage(BoosterPanel, "Booster")
						end,
					},
				},
			},
			Scope:Frame {
				Name = "AttributionBar",
				Visible = Scope:Computed(function(Use)
					return Use(SelectedCreditLink) ~= ""
				end),
				List = {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
				},

				[Children] = {
					Scope:Icon {
						Image = Scope:Computed(function(Use)
							return Use(SelectedCreditSafe).Image
						end),
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1.25"]), Use(Theme.TextSize["1.25"]))
						end),

						OnActivate = function()
							Panel.PagesData.About.SelectedCredit:set(nil)
						end,
					},
					Scope:Frame {
						Flex = {
							Mode = Enum.UIFlexMode.Fill,
						},
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							FillDirection = Enum.FillDirection.Horizontal,
						},

						[Children] = {
							Scope:TextInput {
								Text = SelectedCreditLink,
								TextEditable = false,
								Flex = {
									Mode = Enum.UIFlexMode.Fill,
								},
							},
							Scope:IconButton {
								Name = "BuyButton",
								Image = CONFIG.Icons.DownloadFill,
								Padding = {
									Top = Scope:UDim(0, Theme.Spacing["0.5"]),
									Left = Scope:UDim(0, Theme.Spacing["0.5"]),
									Right = Scope:UDim(0, Theme.Spacing["0.5"]),
									Bottom = Scope:UDim(0, Theme.Spacing["0.5"]),
								},
								Visible = Scope:Computed(function(Use)
									return string.find(Use(SelectedCreditLink), "create.roblox.com/store/asset")
								end),

								OnActivate = function()
									local AssetId = string.match(Fusion.peek(SelectedCreditLink), "asset/(%d+)")

									if (AssetId ~= nil) and (Players.LocalPlayer ~= nil) then
										MarketplaceService:PromptPurchase(Players.LocalPlayer, AssetId)
									end
								end,
							},
						},
					},
				},
			},
		},
	}))
end
