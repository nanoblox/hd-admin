local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local UserStateMod = require(UI.StateMods.UserStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local InfoCard = require(script.Parent.Parent.InfoCard)
local CustomButton = require(script.Parent.Parent.CustomButton)
local RolesReel = require(script.Parent.Parent.RolesReel)

local MODERATION_ACTIONS = {
	{
		Name = "Kick",
		Content = { "Kick", CONFIG.Icons.Close },
		Command = "Kick",
	},
	{
		Name = "Ban",
		Content = { "Ban", CONFIG.Icons.ProhibitedFill },
		Command = "Ban",
	},
}

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		InfoCard = InfoCard,
		CustomButton = CustomButton,
		RolesReel = RolesReel,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local UserId = Panel.PagesData.User.UserId
	local UserInfo = UserStateMod.GetSafe(Scope, UserStateMod.Get(Scope, UserId))

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Scroller {
				ClipsDescendants = true,
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},

				[Children] = {
					Scope:Frame {
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						},

						[Children] = {
							Scope:Frame {
								List = {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
									VerticalAlignment = Enum.VerticalAlignment.Center,
								},

								[Children] = {
									Scope:Avatar {
										Image = Scope:Computed(function(Use)
											return `rbxthumb://type=AvatarHeadShot&id={Use(UserId)}&w=150&h=150`
										end),
										Size = Scope:Computed(function(Use)
											return UDim2.fromOffset(Use(Theme.TextSize["3"]), Use(Theme.TextSize["3"]))
										end),
										Corner = {
											Radius = Scope:UDim(0, Theme.CornerRadius.Full),
										},
									},
									Scope:Frame {
										List = {
											Padding = Scope:UDim(0, Theme.Spacing["0"]),
										},

										[Children] = {
											Scope:Heading {
												Text = Scope:Computed(function(Use)
													return `{Use(UserInfo).DisplayName}`
												end),
												TextWrapped = false,
												HeadingSize = 1.5,
											},
											Scope:Text {
												Text = Scope:Computed(function(Use)
													return `@{Use(UserInfo).Username}`
												end),
												TextColor3 = Theme.Colors.NeutralContent.Dark,
											},
										},
									},
								},
							},
							Scope:RolesReel {
								Roles = Scope:Computed(function(Use)
									local UserInfoValue = Use(UserInfo)

									return UserInfoValue.Roles
								end),
								UserId = UserId,
								Truncated = false,
							},
						},
					},
					Scope:Frame {
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							Wraps = true,
						},

						[Children] = {
							Scope:ForValues(
								Scope:Computed(function(Use)
									local UserInfoValue = Use(UserInfo)

									local LatestBan = UserInfoValue.Bans[#UserInfoValue.Bans] or {}
									local BanTimeRemaining = os.time()
										- ((LatestBan.Timestamp or 0) + (LatestBan.Duration or -1))

									if (LatestBan.Duration or -1) == -1 then
										BanTimeRemaining = -1
									end

									return {
										{
											Title = { "Account", CONFIG.Icons.Info },
											Body = `Joined: {DateTime.fromUnixTimestamp(UserInfoValue.AccountAge)
												:FormatLocalTime("LL", "en-us")}\n\nAge Verified: {UserInfoValue.AgeVerified}`,
										},
										{
											Title = { "Banned", CONFIG.Icons.ProhibitedFill },
											Body = `{DateTime.fromUnixTimestamp(LatestBan.Timestamp or 0)
												:FormatLocalTime("LL", "en-us")}\n\n{BanTimeRemaining > 0 and `{BanTimeRemaining} remaining` or "Indefinite"}`,
											Highlighted = LatestBan ~= nil,
										},
									}
								end),
								function(Use, Scope, InfoCardItem)
									return OnyxUI.Themer.Theme:is(Use(Theme)):during(function()
										return PanelsStateMod.Panel:is(Panel):during(function()
											return Scope:InfoCard {
												Title = InfoCardItem.Title,
												Body = InfoCardItem.Body,
												Size = Scope:Computed(function(Use)
													return UDim2.fromScale(0.5, 0)
														+ UDim2.fromOffset(
															-Use(Theme.Spacing["0.5"]),
															Use(Theme.Spacing["8"]) * 1.25
														)
												end),
												AutomaticSize = Enum.AutomaticSize.None,
												Stroke = {
													Color = Scope:Computed(function(Use)
														local HighlightedValue = Use(InfoCardItem.Highlighted)

														if HighlightedValue then
															return Use(Theme.Colors.Primary.Main)
														else
															return Use(Theme.Colors.Neutral.Main)
														end
													end),
												},
											}
										end)
									end)
								end
							),
						},
					},
				},
			},
			Scope:Frame {
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(MODERATION_ACTIONS, function(Use, Scope, Action)
						return Scope:Button {
							Content = Action.Content,
							ContentSize = Theme.TextSize["1"],
							SizeVariant = "ExtraLarge",
							Color = Theme.Colors.Primary.Main,

							OnActivate = function()
								Panel.PagesData.Execute.CommandId:set(Action.Command)
								PanelsStateMod.ToPage(Panel, "Execute")
							end,
						}
					end),
				},
			},
		},
	}))
end
