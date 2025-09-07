local Players = game:GetService("Players")

local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.ButtonProps & {
	Content: Fusion.UsedAs<string>?,
	Checked: Fusion.UsedAs<boolean>?,
	OnCheck: Fusion.UsedAs<(boolean) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Content = OnyxUI.Util.Fallback(Props.Content, "")
	local Checked = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Checked, false))
	local OnCheck = OnyxUI.Util.Fallback(Props.OnCheck, function() end)

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		Padding = {
			Top = Scope:UDim(0, Theme.Padding["0.75"]),
			Left = Scope:UDim(0, Theme.Padding["0.75"]),
			Right = Scope:UDim(0, Theme.Padding["0.75"]),
			Bottom = Scope:UDim(0, Theme.Padding["0.75"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			Checked:set(not Fusion.peek(Checked))
			Fusion.peek(OnCheck)(Fusion.peek(Checked))
		end,

		[Children] = {
			Scope:Checkbox {
				Checked = Checked,
				Active = false,
				Interactable = false,
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
			},
			Scope:Text {
				Text = Content,
			},
		},
	}, { "Content" }))
end
