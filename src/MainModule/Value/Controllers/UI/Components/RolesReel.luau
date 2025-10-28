local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI

local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)
local Sift = require(Packages.Sift)
local Config = require(UI.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

local RoleBadge = require(script.Parent.RoleBadge)
local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.ScrollerProps & {
	Roles: Fusion.UsedAs<{ string }>?,
	UserId: Fusion.UsedAs<number>?,
	Truncated: Fusion.UsedAs<boolean>?,
	BadgeProps: Fusion.UsedAs<OnyxUI.BadgeProps>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		RoleBadge = RoleBadge,
		CustomButton = CustomButton,
	})

	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Roles = OnyxUI.Util.Fallback(Props.Roles, {})
	local UserId = OnyxUI.Util.Fallback(Props.UserId, nil)
	local Truncated = OnyxUI.Util.Fallback(Props.Truncated, true)
	local BadgeProps = OnyxUI.Util.Fallback(Props.BadgeProps, {
		Padding = {
			Left = Scope:UDim(0, Theme.Spacing["0.5"]),
			Right = Scope:UDim(0, Theme.Spacing["0.5"]),
			Top = Scope:UDim(0, Theme.Spacing["0.25"]),
			Bottom = Scope:UDim(0, Theme.Spacing["0.25"]),
		},
	})

	local SortedRoles = Scope:Computed(function(Use)
		local RolesValue = Use(Roles)

		return Sift.Array.sort(RolesValue, function(RoleIdA, RoleIdB)
			local RoleA = CONFIG.Roles[RoleIdA] or {
				Level = 0,
			}
			local RoleB = CONFIG.Roles[RoleIdB] or {
				Level = 0,
			}

			return RoleA.Level > RoleB.Level
		end)
	end)
	local ShownRoles = Scope:Computed(function(Use)
		local SortedRolesValue = Use(SortedRoles)
		local TruncatedValue = Use(Truncated)

		if TruncatedValue then
			return { SortedRolesValue[1] }
		else
			return SortedRolesValue
		end
	end)

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		AutomaticSize = Enum.AutomaticSize.XY,
		Padding = {
			All = Scope:UDim(0, Theme.StrokeThickness["1"]),
		},
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
		},

		[Children] = {
			Scope:ForValues(ShownRoles, function(Use, Scope, Role: string)
				return OnyxUI.Themer.Theme:is(Theme):during(function()
					return PanelsStateMod.Panel:is(Panel):during(function()
						return Scope:RoleBadge(OnyxUI.Util.CombineProps(BadgeProps, {
							Id = Role,
							UserId = UserId,
						}))
					end)
				end)
			end),
			Scope:Computed(function(Use)
				local RolesValue = Use(Roles)
				local TruncatedValue = Use(Truncated)

				if TruncatedValue and (#RolesValue > 1) then
					return Scope:Badge(OnyxUI.Util.CombineProps(BadgeProps, {
						Name = "TruncationCount",
						Content = { `+{#RolesValue - 1}` },
						ContentColor = Theme.Colors.NeutralContent.Dark,
					}))
				end
			end),
			Scope:Computed(function(Use)
				local TruncatedValue = Use(Truncated)

				if not TruncatedValue then
					return Scope:IconButton {
						Image = CONFIG.Icons.Add,
						Color = Theme.Colors.Base.Main,
						Corner = {
							Radius = Scope:UDim(0, Theme.CornerRadius.Full),
						},
						Stroke = {
							Color = Theme.Colors.Neutral.Main,
							Gradient = {
								Enabled = false,
							},
						},

						OnActivate = function()
							Panel.PagesData.Execute.CommandId:set("role")
							PanelsStateMod.ToPage(Panel, "Execute")
						end,
					}
				end
			end),
		},
	}))
end
