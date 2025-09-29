local deprecateWarnOnce = require(script.Util.DeprecateWarnOnce)

local GetContrastRatioCompat = require(script.GetContrastRatioCompat)
local WCAG = require(script.WCAG)

--[=[
	@class ColorUtils
]=]
local module = {
	-- Methods --
	Darken = require(script.Darken),
	Desaturate = require(script.Desaturate),
	Emphasize = require(script.Emphasize),
	GetLuminance = require(script.GetLuminance),
	GetPerceivedBrightness = require(script.GetPerceivedBrightness),
	Invert = require(script.Invert),
	isDark = require(script.isDark),
	isLight = require(script.isLight),
	Lighten = require(script.Lighten),
	Rotate = require(script.Rotate),
	Saturate = require(script.Saturate),

	-- Submodules --
	APCA = require(script.APCA),
	Blend = require(script.Blend),
	Blind = require(script.Blind),
	Hex = require(script.Hex),
	HSL = require(script.HSL),
	Int = require(script.Int),
	LAB = require(script.LAB),
	LCH = require(script.LCH),
	Palette = require(script.Palette),
	WCAG = WCAG,
}

-- Deprecated methods --
module.Emphasise =
	deprecateWarnOnce(module.Emphasize)("ColorUtils.Emphasise", "ColorUtils.Emphasize") :: typeof(module.Emphasize)

module.GetContrastingColor = deprecateWarnOnce(WCAG.GetContrastingColor)(
	"ColorUtils.GetContrastingColor",
	"WCAG.GetContrastingColor"
) :: typeof(WCAG.GetContrastingColor)

module.GetContrastingColour = deprecateWarnOnce(module.GetContrastingColor)(
	"ColorUtils.GetContrastingColour",
	"WCAG.GetContrastingColor"
) :: typeof(module.GetContrastingColor)

module.GetContrastRatio = deprecateWarnOnce(GetContrastRatioCompat)(
	"ColorUtils.GetContrastRatio",
	"WCAG.GetContrastRatio"
) :: typeof(GetContrastRatioCompat)

return module
