local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local Sift = require(Packages.Sift)
local UserInformant = require(UI.Utils.UserInformant)

local Children = Fusion.Children

export type Props = OnyxUI.FrameProps & {
	UserId: Fusion.UsedAs<string>?,
	Label: Fusion.UsedAs<{ string }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, 1)

	local UserInfo = Scope:Value(nil)
	local UserInfoSafe = Scope:Computed(function(Use)
		local UserInfoValue = Use(UserInfo) or {}

		return Sift.Dictionary.merge({
			UserId = 1,
			Username = "Username",
			DisplayName = "Name",
		}, UserInfoValue)
	end)

	local function UpdateDetails()
		local UserIdValue = Fusion.peek(UserId)

		UserInfo:set(UserInformant.User(UserIdValue))
	end

	Scope:Observer(UserId):onChange(function()
		UpdateDetails()
	end)
	task.spawn(function()
		UpdateDetails()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
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
							return `{Use(UserInfoSafe).DisplayName}`
						end),
						TextWrapped = false,
					},
					Scope:Text {
						Text = Scope:Computed(function(Use)
							return `@{Use(UserInfoSafe).Username}`
						end),
						TextColor3 = Theme.Colors.NeutralContent.Dark,
						TextWrapped = false,
					},
				},
			},
		},
	}))
end
