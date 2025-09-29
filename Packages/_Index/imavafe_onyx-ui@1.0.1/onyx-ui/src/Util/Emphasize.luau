--[=[
  @function Emphasize
  @within Util

  @param Color Color3
  @param Emphasis number
  @return Color3

  Lightens/darkens the given color, with respect to "true" (perceived) brightness.

  Check out [ColorUtils](https://github.com/cxmeel/colour-utils) for a more comprehensive set of color utilities.
]=]

local OnyxUI = script.Parent.Parent
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local function Emphasize(Color: Color3, Emphasis: number): Color3
	return ColorUtils.Emphasize(Color, Emphasis * (1 + ColorUtils.GetPerceivedBrightness(Color)))
end

return Emphasize
