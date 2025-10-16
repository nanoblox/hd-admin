local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local Config = require(UI.Config)
local UserInformant = require(UI.Utils.UserInformant)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local InfoCard = require(script.Parent.Parent.InfoCard)
local CustomButton = require(script.Parent.Parent.CustomButton)
local RolesReel = require(script.Parent.Parent.RolesReel)

local INFO_CARDS = {
	{
		Title = { "Rank", CONFIG.Icons.ShieldPersonFill },
		Body = "User",
	},
	{
		Title = { "Warns", CONFIG.Icons.WarningFill },
		Body = "0",
	},
	{
		Title = { "Banned", CONFIG.Icons.ProhibitedFill },
		Body = "Sep 20, 2024\n30d remaining",
	},
	{
		Title = { "Ban note", CONFIG.Icons.NotepadFill },
		Body = "Lorem ipsum dolor sit amet, consectetur.",
	},
}
local MODERATION_ACTIONS = {
	{
		Name = "Warn",
		Content = { CONFIG.Icons.WarningFill },
	},
	{
		Name = "Kick",
		Content = { CONFIG.Icons.Close },
	},
	{
		Name = "Ban",
		Content = { CONFIG.Icons.ProhibitedFill },
	},
	{
		Name = "Rank",
		Content = { CONFIG.Icons.ShieldPersonFill },
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
	local UserInfo = Scope:Value({})

	local function UpdateUserInfo()
		local UserIdValue = Fusion.peek(UserId)

		UserInfo:set({
			UserId = UserIdValue,
		})

		UserInfo:set(Sift.Dictionary.merge({
			UserId = 1,
			Username = "Username",
			DisplayName = "Name",
		}, UserInformant.User(UserIdValue)))
	end

	Scope:Observer(UserId):onChange(function()
		UpdateUserInfo()
	end)
	task.spawn(function()
		UpdateUserInfo()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Scroller {
				Name = "Page",
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
						Name = "Details",
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						},

						[Children] = {
							Scope:Frame {
								Name = "NameAndPicture",
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
										Name = "Names",
										List = {
											Padding = Scope:UDim(0, Theme.Spacing["0"]),
										},

										[Children] = {
											Scope:Heading {
												Name = "DisplayName",
												Text = Scope:Computed(function(Use)
													return `{Use(UserInfo).DisplayName}`
												end),
												TextWrapped = false,
												HeadingSize = 1.5,
											},
											Scope:Text {
												Name = "Username",
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
								Roles = { "Admin", "Mod" },
								UserId = UserId,
								Truncated = false,
							},
						},
					},
					Scope:Frame {
						Name = "InfoCards",
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
							Wraps = true,
						},

						[Children] = {
							Scope:ForValues(INFO_CARDS, function(Use, Scope, InfoCardItem)
								return OnyxUI.Themer.Theme:is(Use(Theme)):during(function()
									return Scope:InfoCard {
										Title = InfoCardItem.Title,
										Body = InfoCardItem.Body,
										Size = Scope:Computed(function(Use)
											return UDim2.fromScale(0.5, 0)
												+ UDim2.fromOffset(-Use(Theme.Spacing["0.5"]), 16 * 6)
										end),
										AutomaticSize = Enum.AutomaticSize.None,
									}
								end)
							end),
						},
					},
				},
			},
			Scope:Frame {
				Name = "ActionButtons",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(MODERATION_ACTIONS, function(Use, Scope, Action)
						return Scope:Button {
							Name = `{Action.Name}Button`,
							Content = Action.Content,
							SizeVariant = "ExtraLarge",
						}
					end),
				},
			},
		},
	}))
end
