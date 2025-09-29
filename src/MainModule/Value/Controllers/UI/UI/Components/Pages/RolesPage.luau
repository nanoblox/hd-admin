local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Sift = require(HDAdminUI.Parent.Parent.Parent.Packages.Sift)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Users = require(script.Parent.Parent.Users)
local RoleButton = require(script.Parent.Parent.RoleButton)
local Category = require(script.Parent.Parent.Category)
local UserButton = require(script.Parent.Parent.UserButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Users = Users,
		RoleButton = RoleButton,
		UserButton = UserButton,
		Category = Category,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local ActiveTab = Scope:Value(1)

	local MemberCategories = Scope:Computed(function(Use)
		local UserProfilesValue = Use(States.Users.Profiles)

		return Sift.Array.map(CONFIG.Roles, function(Role)
			return {
				Label = { Role },
				Users = Sift.Dictionary.values(
					Sift.Dictionary.map(
						Sift.Dictionary.filter(UserProfilesValue, function(UserProfile)
							return UserProfile.Role == Role
						end),
						function(UserProfile)
							return UserProfile.UserId
						end
					)
				),
			}
		end)
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
									Scope:ForValues(CONFIG.Roles, function(Use, Scope, Role)
										return OnyxUI.Themer.Theme:is(Theme):during(function()
											return Scope:RoleButton {
												Role = Role,
											}
										end)
									end),
								},
							}
						elseif ActiveTabValue == 2 then
							return Scope:ForValues(MemberCategories, function(Use, Scope, Category)
								return OnyxUI.Themer.Theme:is(Theme):during(function()
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
													return Font.new(Use(Theme.Font.Body), Use(Theme.FontWeight.Bold))
												end),
												ContentWrapped = false,
											},
											Scope:Users {
												UserIds = Category.Users,
												ButtonType = "Button",
											},
										},
									}
								end)
							end)
						end
					end),
				},
			},
		},
	}))
end
