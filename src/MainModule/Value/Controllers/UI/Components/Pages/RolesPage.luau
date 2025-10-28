local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Sift = require(Packages.Sift)
local States = require(UI.States)
local Config = require(UI.Config)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Users = require(script.Parent.Parent.Users)
local RoleButton = require(script.Parent.Parent.RoleButton)
local Category = require(script.Parent.Parent.Category)
local UserButton = require(script.Parent.Parent.UserButton)
local RolesReel = require(script.Parent.Parent.RolesReel)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Users = Users,
		RoleButton = RoleButton,
		UserButton = UserButton,
		Category = Category,
		RolesReel = RolesReel,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local ActiveTab = Scope:Value(1)

	local MemberCategories = Scope:Computed(function(Use)
		local UserProfilesValue = Use(States.Users.Profiles)

		return Sift.Dictionary.values(Sift.Dictionary.map(CONFIG.Roles, function(Role, Id)
			return {
				Label = { Role.Name },
				Users = Sift.Dictionary.values(
					Sift.Dictionary.map(
						Sift.Dictionary.filter(UserProfilesValue, function(UserProfile)
							return table.find(UserProfile.Roles, Id)
						end),
						function(UserProfile)
							return UserProfile.UserId
						end
					)
				),
			},
				Id
		end))
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Tabs {
				Tabs = {
					{ "Roles" },
					{ "Members" },
				},
				Tab = ActiveTab,
				ButtonProps = {
					SizeVariant = "Large",
					ContentSize = Theme.TextSize["1"],
					AutomaticSize = Enum.AutomaticSize.Y,
				},
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
			},
			Scope:Scroller {
				ScrollBarThickness = 0,
				ScrollBarImageTransparency = 1,
				CanvasSize = UDim2.fromOffset(0, 0),
				Padding = {
					All = Scope:UDim(0, Theme.StrokeThickness["1"]),
				},
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["1"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Computed(function(Use)
						local ActiveTabValue = Use(ActiveTab)

						if ActiveTabValue == 1 then
							return Scope:Frame {
								List = {
									Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
									HorizontalFlex = Enum.UIFlexAlignment.Fill,
								},

								[Children] = {
									Scope:ForPairs(CONFIG.Roles, function(Use, Scope, Id, _)
										return Id,
											OnyxUI.Themer.Theme:is(Theme):during(function()
												return PanelsStateMod.Panel:is(Panel):during(function()
													return Scope:RoleButton {
														Id = Id,
													}
												end)
											end)
									end),
								},
							}
						elseif ActiveTabValue == 2 then
							return Scope:ForValues(MemberCategories, function(Use, Scope)
								return OnyxUI.Themer.Theme:is(Theme):during(function()
									return PanelsStateMod.Panel:is(Panel):during(function()
										return Scope:Frame {
											List = {
												Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
												HorizontalFlex = Enum.UIFlexAlignment.Fill,
											},

											[Children] = {
												Scope:IconText {
													Content = Category.Label,
													ContentSize = Theme.TextSize["1.125"],
													ContentFontFace = Scope:Computed(function(Use)
														return Font.new(
															Use(Theme.Font.Body),
															Use(Theme.FontWeight.Bold)
														)
													end),
													ContentWrapped = false,
												},
												Scope:Users {
													UserIds = Category.Users,
													ButtonType = "Button",
													ButtonProps = function(UserInfo)
														return {
															List = {
																VerticalFlex = Enum.UIFlexAlignment.Fill,
															},

															[Children] = {
																Scope:RolesReel {
																	UserId = UserInfo.UserId,
																	Roles = UserInfo.Roles,
																	LayoutOrder = 3,
																	AutomaticSize = Enum.AutomaticSize.X,
																	List = {
																		VerticalAlignment = Enum.VerticalAlignment.Center,
																	},
																},
															},
														}
													end,
												},
											},
										}
									end)
								end)
							end)
						end
					end),
				},
			},
		},
	}))
end
