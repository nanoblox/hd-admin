local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local States = require(HDAdminUI.States)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = OnyxUI.ButtonProps & {
	UserId: Fusion.UsedAs<string>?,
	Label: Fusion.UsedAs<{ string }>?,
	Checked: Fusion.UsedAs<boolean>?,
	OnCheck: Fusion.UsedAs<(boolean) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, 1)
	local Checked = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Checked, false))
	local Label = OnyxUI.Util.Fallback(Props.Label, {})
	local OnCheck = OnyxUI.Util.Fallback(Props.OnCheck, function() end)

	local UserInfo = Scope:Value({})

	local function UpdateUserInfo()
		pcall(function()
			local UserIdValue = Fusion.peek(UserId)

			UserInfo:set(Sift.Dictionary.merge({
				UserId = 1,
				Username = "Username",
				DisplayName = "Name",
			}, UserInformant.User(UserIdValue)))
		end)
	end

	Scope:Observer(UserId):onChange(function()
		UpdateUserInfo()
	end)

	task.spawn(function()
		UpdateUserInfo()
	end)

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
			States.Menu.Pages.User.UserId:set(Fusion.peek(UserId))
			NavigationStateMod:To("User")
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
			Scope:Frame {
				Name = "Details",
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},
				Flex = {
					Mode = Enum.UIFlexMode.Fill,
				},

				[Children] = {
					Scope:Avatar {
						Image = Scope:Computed(function(Use)
							return `rbxthumb://type=AvatarHeadShot&id={Use(UserId)}&w=150&h=150`
						end),
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1.5"]), Use(Theme.TextSize["1.5"]))
						end),
						Corner = {
							Radius = Scope:Computed(function(Use)
								return UDim.new(0, Use(Theme.CornerRadius.Full))
							end),
						},
					},
					Scope:Frame {
						Name = "Details",
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0"]),
						},

						[Children] = {
							Scope:Text {
								Text = Scope:Computed(function(Use)
									return `{Use(UserInfo).DisplayName}`
								end),
								TextWrapped = false,
							},
							Scope:Text {
								Text = Scope:Computed(function(Use)
									return `@{Use(UserInfo).Username}`
								end),
								TextColor3 = Theme.Colors.NeutralContent.Dark,
								TextWrapped = false,
							},
						},
					},
				},
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
