--[=[
		@class Divider
		
		Useful for separating UI into sections.
]=]

--[=[
	@interface DividerProps
	@within Divider
	
	. ... FrameProps -- All Frame properties are accepted.
	.Length UDim -- The length of the divider.
	.FillDirection Enum.FillDirection -- The direction in which the divider fills (Horizontal or Vertical).
	.Color Color3 -- The color of the divider.
	.Transparency number -- The transparency of the divider.
	.Spacing UDim -- The spacing around the divider.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local Children = Fusion.Children

local Frame = require(script.Parent.Frame)
local Components = {
	Frame = Frame,
}

export type Props = Frame.Props & {
	Length: Fusion.UsedAs<UDim>?,
	FillDirection: Fusion.UsedAs<Enum.FillDirection>?,
	Color: Fusion.UsedAs<Color3>?,
	Transparency: Fusion.UsedAs<number>?,
	Spacing: Fusion.UsedAs<UDim>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Length = Util.Fallback(Props.Length, UDim.new(1, 0))
	local FillDirection = Util.Fallback(Props.FillDirection, Enum.FillDirection.Horizontal)
	local Color = Util.Fallback(Props.Color, Theme.Colors.BaseContent.Main)
	local Transparency = Util.Fallback(Props.Transparency, 0.9)
	local Spacing = Util.Fallback(Props.Spacing, Scope:UDim(0, Theme.Spacing["0.5"]))

	local VerticalPadding = Scope:Computed(function(Use)
		if Use(FillDirection) == Enum.FillDirection.Horizontal then
			return Use(Spacing)
		else
			return UDim.new()
		end
	end)
	local HorizontalPadding = Scope:Computed(function(Use)
		if Use(FillDirection) == Enum.FillDirection.Vertical then
			return Use(Spacing)
		else
			return UDim.new()
		end
	end)

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		Size = Scope:Computed(function(Use)
			if Use(FillDirection) == Enum.FillDirection.Horizontal then
				return UDim2.new(Length, UDim.new(0, 0))
			else
				return UDim2.new(UDim.new(0, 0), Use(Length))
			end
		end),
		AutomaticSize = Scope:Computed(function(Use)
			if Use(FillDirection) == Enum.FillDirection.Horizontal then
				return Enum.AutomaticSize.Y
			else
				return Enum.AutomaticSize.X
			end
		end),
		Padding = {
			Top = VerticalPadding,
			Bottom = VerticalPadding,
			Left = HorizontalPadding,
			Right = HorizontalPadding,
		},

		[Children] = {
			Scope:Frame {
				Name = "DividingLine",
				Size = Scope:Computed(function(Use)
					if Use(FillDirection) == Enum.FillDirection.Horizontal then
						return UDim2.new(UDim.new(1, 0), UDim.new(0, Use(Theme.StrokeThickness["1"])))
					else
						return UDim2.new(UDim.new(0, Use(Theme.StrokeThickness["1"])), UDim.new(1, 0))
					end
				end),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundColor3 = Color,
				BackgroundTransparency = Transparency,
			},
		},
	}))
end
