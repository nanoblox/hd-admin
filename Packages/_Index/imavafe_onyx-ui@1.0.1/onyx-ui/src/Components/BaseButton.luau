--[=[
		@class BaseButton
		
		A barebones button component, like if Roblox had a "`Button`" class rather than only a `TextButton`.
]=]

--[=[
	@interface BaseButtonProps
	@within BaseButton

	. ... BaseProps -- All Base properties are accepted.
	.Disabled boolean? -- Whether the button is disabled.
	.OnActivate (() -> ())? -- Callback for when the button is activated.
	.OnHover (() -> ())? -- Callback for when the button is hovered over.
	.OnHoverEnd (() -> ())? -- Callback for when the hover ends.
	.OnHold (() -> ())? -- Callback for when the button is held.
	.OnHoldEnd (() -> ())? -- Callback for when the hold ends.
	.Hovering boolean? -- Whether the button is currently being hovered over.
	.Holding boolean? -- Whether the button is currently being held.
	.HoverSound Sound? -- The sound to play when the button is hovered over.
	.ClickSound Sound? -- The sound to play when the button is clicked.
]=]

local SoundService = game:GetService("SoundService")

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)
local Themer = require(OnyxUI.Themer)

local OnEvent = Fusion.OnEvent

local Base = require(script.Parent.Base)
local Components = {
	Base = Base,
}

export type Props = Base.Props & {
	Disabled: Fusion.UsedAs<boolean>?,

	OnActivate: Fusion.UsedAs<() -> ()>?,
	OnHover: Fusion.UsedAs<() -> ()>?,
	OnHoverEnd: Fusion.UsedAs<() -> ()>?,
	OnHold: Fusion.UsedAs<() -> ()>?,
	OnHoldEnd: Fusion.UsedAs<() -> ()>?,

	Hovering: Fusion.UsedAs<boolean>?,
	Holding: Fusion.UsedAs<boolean>?,

	HoverSound: Fusion.UsedAs<Sound>?,
	ClickSound: Fusion.UsedAs<Sound>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)
	local Theme = Themer.Theme:now()

	local Disabled = Util.Fallback(Props.Disabled, false)
	local OnActivate = Util.Fallback(Props.OnActivate, function() end)
	local OnHover = Util.Fallback(Props.OnHover, function() end)
	local OnHoverEnd = Util.Fallback(Props.OnHoverEnd, function() end)
	local OnHold = Util.Fallback(Props.OnHold, function() end)
	local OnHoldEnd = Util.Fallback(Props.OnHoldEnd, function() end)
	local HoverSound = Util.Fallback(Props.HoverSound, Theme.Sound.Hover)
	local ClickSound = Util.Fallback(Props.ClickSound, Theme.Sound.Click)
	local Active = Util.Fallback(
		Props.Active,
		Scope:Computed(function(Use)
			return not Use(Disabled)
		end)
	)
	local Selectable = Util.Fallback(
		Props.Selectable,
		Scope:Computed(function(Use)
			return not Use(Disabled)
		end)
	)

	local Hovering = Scope:EnsureValue(Util.Fallback(Props.Hovering, false))
	local Holding = Scope:EnsureValue(Util.Fallback(Props.Holding, false))

	return Scope:Hydrate(Scope:Base(Util.CombineProps(Props, {
		ClassName = "TextButton",
		Name = script.Name,
		AutomaticSize = Enum.AutomaticSize.XY,
		Selectable = Selectable,
		BackgroundTransparency = 1,
	}))) {
		Text = "",
		RichText = false,
		TextSize = 0,

		[OnEvent "Activated"] = function()
			if not Fusion.peek(Disabled) then
				SoundService:PlayLocalSound(Fusion.peek(ClickSound))

				Fusion.peek(OnActivate)()
			end
		end,
		[OnEvent "MouseEnter"] = function()
			if Fusion.peek(Active) then
				SoundService:PlayLocalSound(Fusion.peek(HoverSound))
			end

			Hovering:set(true)

			Fusion.peek(OnHover)()
		end,
		[OnEvent "SelectionGained"] = function()
			if Fusion.peek(Active) then
				SoundService:PlayLocalSound(Fusion.peek(HoverSound))
			end

			Hovering:set(true)

			Fusion.peek(OnHover)()
		end,
		[OnEvent "SelectionLost"] = function()
			Hovering:set(false)
			Holding:set(false)

			Fusion.peek(OnHoverEnd)()
		end,
		[OnEvent "MouseLeave"] = function()
			Hovering:set(false)
			Holding:set(false)

			Fusion.peek(OnHoverEnd)()
		end,
		[OnEvent "MouseButton1Down"] = function()
			if not Fusion.peek(Disabled) then
				Holding:set(true)

				Fusion.peek(OnHold)()
			end
		end,
		[OnEvent "MouseButton1Up"] = function()
			Holding:set(false)

			Fusion.peek(OnHoldEnd)()
		end,
	}
end
