--[[
	This is a Luau implementation of the APAC method of calculating the contrast
	ratio between two colors.

	This APAC method is based around a few different implementations:

	> Visual Contrast by W3C
	> https://w3c.github.io/silver/guidelines/methods/Method-font-characteristic-contrast.html#section3

	> Google Chrome
	> https://chromium.googlesource.com/devtools/devtools-frontend/+/c88c76b465f2dc8a853fe2a0997ccbfbff0e5bac/front_end/common/ColorUtils.js#88

	> Answer by @myndex on StackOverflow
	> https://stackoverflow.com/a/69411415

	> Contrast by @cliambrown
	> https://github.com/cliambrown/contrast/blob/master/src/apca.js
]]
local Assert = require(script.Parent.Parent.Util.Assert)
local CONST = require(script.Parent.Const)

local assertTypeOf = Assert.prepTypeOf("GetContrastRatioAPCA")

local abs = math.abs

local function ComputePower(value: number): number
	return value ^ CONST.SRGB_TRC
end

local function ComputeY(color: Color3): number
	return ComputePower(color.R) * CONST.RED_COEF
		+ ComputePower(color.G) * CONST.GREEN_COEF
		+ ComputePower(color.B) * CONST.BLUE_COEF
end

local function SoftClampBlack(y: number): number
	return if y > CONST.BLK_THRS then y else y + abs(y - CONST.BLK_THRS) ^ CONST.BLK_CLMP
end

--[=[
	@function GetContrastRatio
	@within APCA

	@param foreground Color3 -- The foreground color.
	@param background Color3 -- The background color.
	@return number -- The contrast ratio [≈-100-100].
]=]
local function GetContrastRatio(foreground: Color3, background: Color3): number
	assertTypeOf("foreground", "Color3", foreground)
	assertTypeOf("background", "Color3", background)

	local sapc = 0
	local outputContrast = 0

	local fgY = SoftClampBlack(ComputeY(foreground))
	local bgY = SoftClampBlack(ComputeY(background))

	if abs(bgY - fgY) < CONST.MIN_DELTA_Y then
		return 0
	end

	if bgY > fgY then
		sapc = (bgY ^ CONST.NORM_BG_EXP - fgY ^ CONST.NORM_FG_EXP) * CONST.SCALE_BOW

		outputContrast = if sapc < CONST.LOW_CLIP
			then 0
			elseif sapc < CONST.LOW_BOW_THRS then sapc - sapc * CONST.LOW_BOW_FACT * CONST.LOW_BOW_OFFS
			else sapc - CONST.LOW_BOW_OFFS
	else
		sapc = (bgY ^ CONST.REV_BG_EXP - fgY ^ CONST.REV_FG_EXP) * CONST.SCALE_WOB

		outputContrast = if sapc > -CONST.LOW_CLIP
			then 0
			elseif sapc > -CONST.LOW_WOB_THRS then sapc - sapc * CONST.LOW_WOB_FACT * CONST.LOW_WOB_OFFS
			else sapc + CONST.LOW_WOB_OFFS
	end

	return outputContrast * 100
end

return GetContrastRatio
