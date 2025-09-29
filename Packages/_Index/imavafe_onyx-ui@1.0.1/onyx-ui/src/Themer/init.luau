--[=[
	@class Themer
	
	Themer allows you to customize components throughout OnyxUI, with support for things like colors, corner radiuses, paddings, etc. You'll also probably want to reference it within your own UI for a more consistent design.
]=]
--[=[
		@within Themer
		@type ThemeSpec table

		A specification table for theme properties. Check out [ThemeSpec.luau](https://github.com/ImAvafe/OnyxUI/blob/main/src/Themer/ThemeSpec.luau) for a full reference of available theme properties.
]=]
--[=[
		@within Themer
		@type Theme table

		An active theme to be referenced in UI.
]=]

local OnyxUI = script.Parent
local OnyxNightTheme = require(script.OnyxNight)
local NewTheme = require(script.NewTheme)
local ThemeSpec = require(script.ThemeSpec)
local Fusion = require(OnyxUI.Parent.Fusion)

local Contextual = Fusion.Contextual

export type ThemeSpec = ThemeSpec.ThemeSpec

local Themer = {}

--[=[
	@function NewTheme
	@within Themer

	@param Scope Fusion.Scope<any>
	@param ThemeSpec ThemeSpec
	@return Theme

	Creates the specified theme.
]=]
function Themer.NewTheme(Scope: Fusion.Scope<any>, ThemeSpec: ThemeSpec)
	return NewTheme(Scope, ThemeSpec)
end

--[=[
	@prop Theme Fusion.Contextual<Theme>
	@within Themer

	The currently active theme. Use `Themer.Theme:now()` to get the active theme, and `Themer.Theme:is(MyTheme):during()` to make code use another theme. See [Fusion Contextuals](https://elttob.uk/Fusion/0.3/tutorials/best-practices/sharing-values/?h=contextuals#contextuals) for more information.
]=]
local Theme: Fusion.Contextual<Theme> = Contextual(OnyxNightTheme)
Themer.Theme = Theme

export type Theme = typeof(Themer.NewTheme(Fusion.scoped(), {}))

return Themer
