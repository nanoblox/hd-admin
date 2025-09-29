local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)

local Children = Fusion.Children

export type Props = OnyxUI.FrameProps & {
	Label: Fusion.UsedAs<{ string }>?,
	LabelSize: Fusion.UsedAs<number>?,
	HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Label = OnyxUI.Util.Fallback(Props.Label, { "Category" })
	local LabelSize = OnyxUI.Util.Fallback(Props.LabelSize, Theme.TextSize["1.5"])
	local HorizontalAlignment = OnyxUI.Util.Fallback(Props.HorizontalAlignment, Enum.HorizontalAlignment.Left)

	local GivenChildren = Props[Children]
	Props[Children] = nil

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["1"]),
			HorizontalAlignment = HorizontalAlignment,
		},

		[Children] = {
			Scope:IconText {
				Name = "Label",
				Content = Label,
				ContentSize = LabelSize,
				ContentFontFace = Scope:Font(Theme.Font.Heading, Theme.FontWeight.Heading),
			},
			Scope:Frame {
				Name = "Content",
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
					HorizontalAlignment = HorizontalAlignment,
				},

				[Children] = {
					GivenChildren,
				},
			},
		},
	}))
end
