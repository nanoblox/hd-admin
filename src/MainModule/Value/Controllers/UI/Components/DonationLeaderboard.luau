local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)

local CONFIG = Config:Get()

local Children = Fusion.Children

local UserButton = require(script.Parent.UserButton)

export type Props = OnyxUI.FrameProps & {}

return function(Scope: Fusion.Scope<>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		UserButton = UserButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Tab = Scope:Value(1)

	local RelevantUsers = Scope:Computed(function(Use)
		local TabSelectionValue = Use(Tab)

		local Users

		if TabSelectionValue == 1 then
			Users = Sift.Array.prepend(CONFIG.Donators.Top, CONFIG.Donators.Local)
		else
			Users = CONFIG.Donators.Recent
		end

		return Sift.Array.filter(Users, function(_, Index: number)
			return Index <= 10
		end)
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},

		[Children] = {
			Scope:Heading {
				Text = "Donators",
				HeadingSize = 1.5,
			},
			Scope:Frame {
				Name = "Filters",
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},

				[Children] = {
					Scope:Tabs {
						Tab = Tab,
						Tabs = { { CONFIG.Icons.StarFill, "Top" }, { CONFIG.Icons.RecentCalendarFill, "Recent" } },
						ButtonProps = {
							SizeVariant = "Large",
							ContentSize = Theme.TextSize["1"],
						},
						List = {
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						},
					},
				},
			},
			Scope:Frame {
				Name = "Donators",
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				Padding = {
					All = Scope:UDim(0, Theme.Spacing["0.25"]),
				},
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				},
				Corner = {
					Radius = Scope:UDim(0, Theme.CornerRadius["1.5"]),
				},

				[Children] = {
					Scope:ForPairs(RelevantUsers, function(Use, Scope, Index: number, Donator)
						return Index,
							OnyxUI.Themer.Theme:is(Theme):during(function()
								return Scope:UserButton {
									UserId = Donator.UserId,
									PrefixLabel = Scope:Computed(function(Use)
										if (Use(Tab) == 1) and (Index > 1) then
											return { `#{Index - 1}` }
										else
											return {}
										end
									end),
									SuffixLabel = { ` {Donator.Amount}` },
									Interactable = false,
									BackgroundTransparency = 1,
									Stroke = {
										Enabled = false,
									},
								}
							end)
					end),
				},
			},
		},
	}))
end
