local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local Config = require(UI.Config)
local Callbacks = require(UI.Callbacks)
local Sift = require(Packages.Sift)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local CONFIG = Config:Get()

local Children = Fusion.Children

export type Props = OnyxUI.ButtonProps & {
	Id: Fusion.UsedAs<string>?,
	UserId: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local Id = OnyxUI.Util.Fallback(Props.Id, "Guest")
	local UserId = OnyxUI.Util.Fallback(Props.UserId, nil)

	local Role = Scope:Computed(function(Use)
		local IdValue = Use(Id)

		return Sift.Dictionary.merge({
			Name = "Guest",
			Color = Color3.fromHex("FFFFFF"),
			Level = 0,
		}, CONFIG.Roles[IdValue] or {})
	end)

	return Scope:Badge(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Padding = {
			Left = Scope:UDim(0, Theme.Spacing["0.5"]),
			Right = Scope:UDim(0, Theme.Spacing["0.5"]),
			Top = Scope:UDim(0, Theme.Spacing["0.25"]),
			Bottom = Scope:UDim(0, Theme.Spacing["0.25"]),
		},
		List = {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
		},

		[Children] = {
			Scope:Frame {
				BackgroundColor3 = Scope:Computed(function(Use)
					return Use(Role).Color
				end),
				BackgroundTransparency = 0,
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Use(Theme.TextSize["1"]) / 2, Use(Theme.TextSize["1"]) / 2)
				end),
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
						Visible = false,
					},
				},
			},
			Scope:IconText {
				Content = Scope:Computed(function(Use)
					return { Use(Id) }
				end),
			},
			Scope:Computed(function(Use)
				local UserIdValue = Use(UserId)
				local RoleValue = Use(Id)

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
							Panel.PagesData.Execute.CommandId:set("RemoveRole")
							PanelsStateMod.ToPage(Panel, "Execute")
						end,
					}
				end
			end),
		},
	}))
end
