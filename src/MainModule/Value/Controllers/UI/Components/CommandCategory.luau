local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local States = require(HDAdminUI.States)

local Children = Fusion.Children
local CommandButton = require(script.Parent.CommandButton)

export type Props = OnyxUI.FrameProps & {
	Commands: Fusion.UsedAs<{ string }>?,
	Label: Fusion.UsedAs<{ string }>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CommandButton = CommandButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Commands = OnyxUI.Util.Fallback(Props.Commands, {})
	local Label = OnyxUI.Util.Fallback(Props.Label, {})

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = Scope:UDim(0, Theme.Spacing["0.75"]),
		},

		[Children] = {
			Scope:Computed(function(Use)
				if #Use(Label) >= 1 then
					return Scope:Frame {
						Name = "Label",
						List = {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
						},

						[Children] = {
							Scope:IconText {
								Content = Label,
								ContentSize = Theme.TextSize["1.125"],
								ContentFontFace = Scope:Computed(function(Use)
									return Font.new(Use(Theme.Font.Body), Use(Theme.FontWeight.Bold))
								end),
								ContentWrapped = false,
							},
						},
					}
				end
			end),
			Scope:Frame {
				Name = "Commands",
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(Commands, function(Use, Scope, CommandId: string)
						return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
							return Scope:CommandButton {
								Id = CommandId,
								QuickRun = States.Menu.Pages.Commands.QuickRun,
							}
						end)
					end),
				},
			},
		},
	}))
end
