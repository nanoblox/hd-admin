local HDAdminUI = script.Parent.Parent
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local States = require(HDAdminUI.States)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

export type Props = CustomButton.Props & {
	Label: Fusion.UsedAs<string>?,
	Image: Fusion.UsedAs<string>?,
	ImageShown: Fusion.UsedAs<boolean>?,
	Link: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Label = OnyxUI.Util.Fallback(Props.Label, "Label")
	local Image = OnyxUI.Util.Fallback(Props.Image, nil)
	local Link = OnyxUI.Util.Fallback(Props.Link, "https://devforum.roblox.com")
	local ImageShown = OnyxUI.Util.Fallback(Props.ImageShown, true)
	local Padding = OnyxUI.Util.Fallback(Props.Padding, Scope:UDim(0, Theme.Padding["0.5"]))

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		List = {
			Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
		},
		Corner = {
			Radius = Scope:UDim(0, Theme.CornerRadius["Full"]),
		},
		Padding = {
			Top = Padding,
			Left = Padding,
			Right = Padding,
			Bottom = Padding,
		},

		OnActivate = function()
			States.Menu.Pages.About.SelectedCredit:set({
				Name = Fusion.peek(Label),
				Image = Fusion.peek(Image),
				Link = Fusion.peek(Link),
			})
		end,

		[Children] = {
			Scope:Computed(function(Use)
				if Use(Image) ~= nil then
					return Scope:Icon {
						Image = Image,
						Visible = ImageShown,
					}
				end
			end),
			Scope:Text {
				Text = Label,
				LayoutOrder = 2,
			},
		},
	}))
end
