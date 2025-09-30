local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local UserInformant = require(HDAdminUI.Utils.UserInformant)
local States = require(script.Parent.Parent.States)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)
local UserDetails = require(script.Parent.UserDetails)

export type Props = OnyxUI.ButtonProps & {
	UserId: Fusion.UsedAs<string>?,
	PrefixLabel: Fusion.UsedAs<{ string }>?,
	SuffixLabel: Fusion.UsedAs<{ string }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
		UserDetails = UserDetails,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, 1)
	local PrefixLabel = OnyxUI.Util.Fallback(Props.PrefixLabel, {})
	local SuffixLabel = OnyxUI.Util.Fallback(Props.SuffixLabel, {})

	return Scope:Button(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		},
		Padding = {
			Left = Scope:UDim(0, Theme.Padding["0.75"]),
			Right = Scope:UDim(0, Theme.Padding["0.75"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
		},

		OnActivate = function()
			local UserIdValue = Fusion.peek(UserId)

			States.Menu.Pages.User.UserId:set(UserIdValue)
			NavigationStateMod:To("User")
		end,

		[Children] = {
			Scope:Computed(function(Use)
				if #Use(PrefixLabel) >= 1 then
					return Scope:IconText {
						Name = "PrefixLabel",
						Content = PrefixLabel,
						ContentWrapped = false,
						ContentColor = Theme.Colors.NeutralContent.Main,
						LayoutOrder = 1,
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
						},
					}
				end
			end),
			Scope:UserDetails {
				UserId = UserId,
				LayoutOrder = 2,
			},
			Scope:Computed(function(Use)
				if #Use(SuffixLabel) >= 1 then
					return Scope:IconText {
						Name = "SuffixLabel",
						Content = SuffixLabel,
						ContentWrapped = false,
						ContentColor = Theme.Colors.NeutralContent.Main,
						LayoutOrder = 3,
						List = {
							Padding = Scope:UDim(0, Theme.Spacing["0.25"]),
						},
					}
				end
			end),
		},
	}))
end
