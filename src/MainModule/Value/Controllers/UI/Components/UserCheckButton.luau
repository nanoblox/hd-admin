local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)
local UserDetails = require(script.Parent.UserDetails)

export type Props = OnyxUI.ButtonProps & {
	UserId: Fusion.UsedAs<string>?,
	Label: Fusion.UsedAs<{ string }>?,
	Checked: Fusion.UsedAs<boolean>?,
	OnCheck: Fusion.UsedAs<(boolean) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
		UserDetails = UserDetails,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Panel = PanelsStateMod.Panel:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, 1)
	local Checked = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Checked, false))
	local Label = OnyxUI.Util.Fallback(Props.Label, {})
	local OnCheck = OnyxUI.Util.Fallback(Props.OnCheck, function() end)

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0"]),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		Padding = {
			Top = Scope:UDim(0, Theme.Spacing["0"]),
			Right = Scope:UDim(0, Theme.Spacing["0.75"]),
			Left = Scope:UDim(0, Theme.Spacing["0"]),
			Bottom = Scope:UDim(0, Theme.Spacing["0"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			Panel.PagesData.User.UserId:set(Fusion.peek(UserId))
			PanelsStateMod.ToPage(Panel, "User")
		end,

		[Children] = {
			Scope:BaseButton {
				Name = "Checkbox",
				Padding = {
					All = Scope:UDim(0, Theme.Spacing["0.75"]),
				},

				OnActivate = function()
					local OnCheckValue = Fusion.peek(OnCheck)
					local CheckedValue = Fusion.peek(Checked)

					Checked:set(not CheckedValue)

					OnCheckValue(not CheckedValue)
				end,

				[Children] = {
					Scope:Checkbox {
						Checked = Checked,
						Corner = {
							Radius = Scope:Computed(function(Use)
								return UDim.new(0, Use(Theme.CornerRadius["1"]))
							end),
						},
						Stroke = {
							Color = Scope:Computed(function(Use)
								if Use(Checked) then
									return Color3.fromRGB(255, 255, 255)
								else
									return Use(Theme.Colors.NeutralContent.Dark)
								end
							end),
							Gradient = {
								Enabled = Checked,
							},
						},
						Active = false,
						Interactable = false,
					},
				},
			},
			Scope:UserDetails {
				UserId = UserId,
			},
			Scope:IconText {
				Name = "Label",
				Content = Label,
				ContentColor = Theme.Colors.NeutralContent.Dark,
				ContentWrapped = false,
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
				},
			},
		},
	}))
end
