local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)

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
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		Padding = {
			Left = Scope:UDim(0, Theme.Padding["0.75"]),
			Right = Scope:UDim(0, Theme.Padding["0.75"]),
			Top = Scope:UDim(0, Theme.Padding["0.5"]),
			Bottom = Scope:UDim(0, Theme.Padding["0.5"]),
		},

		[Children] = {
			Scope:Frame {
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
		},
	}))
end
