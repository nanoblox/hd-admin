local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local States = require(HDAdminUI.States)
local Config = require(HDAdminUI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local PageButton = require(script.Parent.Parent.PageButton)
local Users = require(script.Parent.Parent.Users)
local CustomButton = require(script.Parent.Parent.CustomButton)
local RoleButton = require(script.Parent.Parent.RoleButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		PageButton = PageButton,
		Users = Users,
		CustomButton = CustomButton,
		RoleButton = RoleButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local ActiveTab = Scope:Value(1)

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
				},
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
			},
			Scope:Frame {
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:Computed(function(Use)
						local ActiveTabValue = Use(ActiveTab)

						if ActiveTabValue == 1 then
							return {
								Scope:ForValues(CONFIG.Roles, function(Use, Scope, Role)
									return OnyxUI.Themer.Theme:is(Theme):during(function()
										return Scope:RoleButton {
											Role = Role,
										}
									end)
								end),
							}
						elseif ActiveTabValue == 2 then
							return {
								Scope:Users {
									UserIds = {},
								},
							}
						end
					end),
				},
			},
		},
	}))
end
