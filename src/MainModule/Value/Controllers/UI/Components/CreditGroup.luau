local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local OnyxUI = require(Packages.OnyxUI)
local Fusion = require(Packages.Fusion)
local States = require(UI.States)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local CreditBadge = require(script.Parent.CreditBadge)

export type Credit = {
	Label: Fusion.UsedAs<string>?,
	Image: Fusion.UsedAs<string>?,
	Link: Fusion.UsedAs<string>?,
}
export type Props = OnyxUI.FrameProps & {
	Title: Fusion.UsedAs<{ string }>?,
	Credits: Fusion.UsedAs<{ Credit }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CreditBadge = CreditBadge,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Title = OnyxUI.Util.Fallback(Props.Title, nil)
	local Credits = OnyxUI.Util.Fallback(Props.Credits, {})

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		List = {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		},

		[Children] = {
			Scope:Computed(function(Use)
				if Use(Title) then
					return Scope:Heading {
						Text = Title,
						TextSize = Theme.TextSize["1.25"],
					}
				end
			end),
			Scope:Frame {
				List = {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Wraps = true,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(Credits, function(Use, Scope, Credit: Credit)
						return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
							return PanelsStateMod.Panel:is(Panel):during(function()
								return Scope:CreditBadge {
									Label = Credit.Label,
									Image = Credit.Image,
									Link = Credit.Link,
								}
							end)
						end)
					end),
				},
			},
		},
	}))
end
