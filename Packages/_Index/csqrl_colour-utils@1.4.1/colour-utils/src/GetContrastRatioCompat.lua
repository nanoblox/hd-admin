local getContrastRatio = require(script.Parent.APCA.GetContrastRatio)
local didWarnAPCA = false

local function getContrastRatioCompat(foreground: Color3, background: Color3): number
	local contrastRatio = math.abs(getContrastRatio(foreground, background))

	if not didWarnAPCA then
		didWarnAPCA = true

		warn(
			"ColorUtils.GetContrastRatio is providing a compatibility layer for APCA.GetContrastRatio. To continue using the old behavior, use WCAG.GetContrastRatio instead."
		)
	end

	return (contrastRatio / 100) * 21
end

return getContrastRatioCompat
