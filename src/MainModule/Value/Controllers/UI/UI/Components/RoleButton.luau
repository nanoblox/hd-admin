local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local Signals = require(HDAdminUI.Signals)

local CONFIG = Config:Get()

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.ButtonProps & {
	Role: Fusion.UsedAs<string>?,
	UserId: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {})
	local Theme = OnyxUI.Themer.Theme:now()

	local Role = OnyxUI.Util.Fallback(Props.Role, "Admin")
	local UserId = OnyxUI.Util.Fallback(Props.UserId, nil)

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
		},

		[Children] = {
			Scope:Frame {
				Name = "Marker",
				BackgroundColor3 = Theme.Colors.Error.Main,
				BackgroundTransparency = 0,
				Size = Scope:UDim2Offset(Theme.TextSize["0.75"], Theme.TextSize["0.75"]),
				AutomaticSize = Enum.AutomaticSize.None,
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius.Full),
				},

				[Children] = {
					Scope:Icon {
						Image = CONFIG.Icons.HourglassHalfOutline,
						Size = UDim2.fromScale(0.9, 0.9),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
					},
				},
			},
			Scope:IconText {
				Content = Scope:Computed(function(Use)
					return { Use(Role) }
				end),
			},
			Scope:Computed(function(Use)
				local UserIdValue = Use(UserId)
				local RoleValue = Use(Role)

				if UserIdValue ~= nil then
					return Scope:IconButton {
						Image = CONFIG.Icons.Close,
						ContentSize = Theme.TextSize["0.75"],
						Color = Theme.Colors.NeutralContent.Main,
						Style = "Ghost",
						Padding = {
							Left = Scope:UDim(0, 0),
							Right = Scope:UDim(0, 0),
							Top = Scope:UDim(0, 0),
							Bottom = Scope:UDim(0, 0),
						},

						OnActivate = function()
							Signals.UserRoleRevoked:Fire(UserIdValue, RoleValue)
						end,
					}
				end
			end),
		},
	}))
end
