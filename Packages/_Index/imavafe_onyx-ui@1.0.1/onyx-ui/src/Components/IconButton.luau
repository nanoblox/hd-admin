--[=[
		@class IconButton
		
		Like [`Button`](/api/Button), but for a single [`Icon`](/api/Icon).
]=]

--[=[
		@within IconButton
		@interface IconButtonProps

		. ... ButtonProps -- All Button properties are accepted.
		. Image string?
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Button = require(script.Parent.Button)
local Components = {
	Button = Button,
}

export type Props = Button.Props & {
	Image: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Image = Util.Fallback(Props.Image, "")

	local Padding = Scope:UDim(0, Theme.Spacing["0.25"])

	return Scope:Button(Util.CombineProps(Props, {
		Name = script.Name,
		Padding = {
			Left = Padding,
			Right = Padding,
			Top = Padding,
			Bottom = Padding,
		},
		Content = Scope:Computed(function(Use)
			return { Use(Image) }
		end),
	}))
end
