local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Parent.Packages.OnyxUI)
local Config = require(HDAdminUI.Config)
local States = require(HDAdminUI.States)
local ColorUtils = require(HDAdminUI.Parent.Parent.Parent.Packages.ColorUtils)
local NavigationStateMod = require(HDAdminUI.StateMods.NavigationStateMod)
local Pages = require(HDAdminUI.Static.Pages)

local CONFIG = Config:Get()

local Children = Fusion.Children

local Dragger = require(HDAdminUI.Components.Dragger)

export type Props = OnyxUI.FrameProps & {
	Content: Fusion.UsedAs<string>?,
	Color: Fusion.UsedAs<Color3>?,
	OnDrag: Fusion.UsedAs<(DeltaPosition: Vector2) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Dragger = Dragger,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Content = OnyxUI.Util.Fallback(Props.Content, {})
	local Color = OnyxUI.Util.Fallback(Props.Color, Theme.Colors.Primary.Main)
	local OnDrag = OnyxUI.Util.Fallback(Props.OnDrag, function() end)

	local ContentColor = Scope:Computed(function(Use)
		local ColorValue = Use(Color)

		return ColorUtils.Emphasize(ColorValue, 1)
	end)
	local Page = Scope:Computed(function(Use)
		return Pages[Use(States.Menu.Page)]
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		BackgroundTransparency = 0,
		Padding = {
			All = Scope:UDim(0, Theme.Padding["0.5"]),
		},
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		Gradient = {
			Color = Scope:Computed(function(Use)
				return ColorSequence.new(Use(Color), ColorUtils.Emphasize(Use(Color), 0.1))
			end),
			Rotation = -90,
		},

		[Children] = {
			Scope:Dragger {
				OnDrag = function(OldPosition, NewPosition)
					local OnDragValue = Fusion.peek(OnDrag)

					local DeltaPosition = NewPosition - OldPosition

					OnDragValue(DeltaPosition)
				end,
			},
			Scope:IconButton {
				Name = "BackButton",
				Style = "Ghost",
				Image = CONFIG.Icons.ArrowLeft,
				ContentSize = Theme.TextSize["1.25"],
				Color = ContentColor,
				Disabled = Scope:Computed(function(Use)
					local PageIdValue = Use(States.Menu.Page)
					local PageValue = Use(Page)

					if PageIdValue == "Dashboard" then
						return true
					elseif PageValue ~= nil then
						return PageValue.NavigationLocked
					else
						return false
					end
				end),

				OnActivate = function()
					NavigationStateMod:Undo()
				end,
			},
			Scope:IconText {
				Name = "Title",
				Content = Content,
				ContentSize = Theme.TextSize["1.25"],
				ContentFontFace = Scope:Computed(function(Use)
					return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
				end),
				ContentColor = ContentColor,
				ContentWrapped = false,
				List = {
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},
			},
			Scope:IconButton {
				Name = "CloseButton",
				Style = "Ghost",
				Image = CONFIG.Icons.Close,
				ContentSize = Theme.TextSize["1.25"],
				Color = ContentColor,
				Disabled = Scope:Computed(function(Use)
					local PageValue = Use(Page)

					return PageValue.NavigationLocked == true
				end),

				OnActivate = function()
					States.Menu.Open:set(false)
				end,
			},
		},
	}))
end
