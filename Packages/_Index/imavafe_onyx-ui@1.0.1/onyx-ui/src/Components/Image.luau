--[=[
		@class Image
		
		Equivalent to Roblox's `ImageLabel`.
]=]

--[=[
	@interface ImageProps
	@within Image
	
	. ... BaseProps -- All Base properties are accepted.
	.Image string? -- The image asset ID to display.
	.FallbackImage string? -- The fallback image asset ID to display if `Image` is not provided.
	.ImageColor3 Color3? -- The color to apply to the image.
	.ImageTransparency number? -- The transparency of the image.
	.ImageRectOffset Vector2? -- The offset of the image rectangle.
	.ImageRectSize Vector2? -- The size of the image rectangle.
	.ResampleMode Enum.ResamplerMode? -- The resampling mode for the image.
	.ScaleType Enum.ScaleType? -- The scaling mode for the image.
	.SliceCenter Rect? -- The center rectangle for 9-slice scaling.
	.SliceScale number? -- The scale factor for 9-slice scaling.
	.TileSize UDim2? -- The size of the tile for tiled images.
]=]

local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)
local Util = require(OnyxUI.Util)

local Base = require(script.Parent.Base)
local Components = {
	Base = Base,
}

export type Props = Base.Props & {
	Image: Fusion.UsedAs<string>?,
	FallbackImage: Fusion.UsedAs<string>?,
	ImageColor3: Fusion.UsedAs<Color3>?,
	ImageTransparency: Fusion.UsedAs<number>?,
	ImageRectOffset: Fusion.UsedAs<Vector2>?,
	ImageRectSize: Fusion.UsedAs<Vector2>?,
	ResampleMode: Fusion.UsedAs<Enum.ResamplerMode>?,
	ScaleType: Fusion.UsedAs<Enum.ScaleType>?,
	SliceCenter: Fusion.UsedAs<Rect>?,
	SliceScale: Fusion.UsedAs<number>?,
	TileSize: Fusion.UsedAs<UDim2>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, Components)

	local FallbackImage = Util.Fallback(Props.FallbackImage, "rbxasset://textures/ui/GuiImagePlaceholder.png")
	local Image = Util.Fallback(Props.Image, nil)

	local ImageInUse = Scope:Computed(function(Use)
		if Use(Image) then
			return Use(Image)
		else
			return Use(FallbackImage)
		end
	end)

	return Scope:Hydrate(Scope:Base(Util.CombineProps(Props, {
		ClassName = "ImageLabel",
		Name = script.Name,
		Size = UDim2.fromOffset(100, 100),
		AutomaticSize = Enum.AutomaticSize.None,
	}))) {
		Image = ImageInUse,
		ImageColor3 = Props.ImageColor3,
		ImageTransparency = Props.ImageTransparency,
		ImageRectOffset = Props.ImageRectOffset,
		ImageRectSize = Props.ImageRectSize,
		ResampleMode = Props.ResampleMode,
		ScaleType = Props.ScaleType,
		SliceCenter = Props.SliceCenter,
		SliceScale = Props.SliceScale,
		TileSize = Props.TileSize,
	}
end
