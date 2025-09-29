local OnyxUI = script.Parent.Parent
local Fusion = require(OnyxUI.Parent.Fusion)

local Unit = {}

--[=[
	@function Vector2
	@within Util

	@param Scope Fusion.Scope(typeof(Fusion))
	@param X Fusion.UsedAs<number>
	@param Y Fusion.UsedAs<number>
	@return Fusion.Computed<Vector2>
]=]
function Unit.Vector2(
	Scope: Fusion.Scope<typeof(Fusion)>,
	X: Fusion.UsedAs<number>,
	Y: Fusion.UsedAs<number>
): Fusion.Computed<Vector2>
	return Scope:Computed(function(Use)
		return Vector2.new(Use(X), Use(Y))
	end)
end

--[=[
	@function UDim
	@within Util

	@param Scope Fusion.Scope<typeof(Fusion)>
	@param Scale Fusion.UsedAs<number>
	@param Offset Fusion.UsedAs<number>
	@return Fusion.Computed<UDim>
]=]
function Unit.UDim(
	Scope: Fusion.Scope<typeof(Fusion)>,
	Scale: Fusion.UsedAs<number>,
	Offset: Fusion.UsedAs<number>
): Fusion.Computed<UDim>
	return Scope:Computed(function(Use)
		return UDim.new(Use(Scale), Use(Offset))
	end)
end

--[=[
	@function UDim2
	@within Util

	@param Scope Fusion.Scope<typeof(Fusion)>
	@param XScale Fusion.UsedAs<number>
	@param XOffset Fusion.UsedAs<number>
	@param YScale Fusion.UsedAs<number>
	@param YOffset Fusion.UsedAs<number>
	@return Fusion.Computed<UDim2>
]=]
function Unit.UDim2(
	Scope: Fusion.Scope<typeof(Fusion)>,
	XScale: Fusion.UsedAs<number>,
	XOffset: Fusion.UsedAs<number>,
	YScale: Fusion.UsedAs<number>,
	YOffset: Fusion.UsedAs<number>
): Fusion.Computed<UDim2>
	return Scope:Computed(function(Use)
		return UDim2.new(Use(XScale), Use(XOffset), Use(YScale), Use(YOffset))
	end)
end

--[=[
	@function UDim2Offset
	@within Util

	@param Scope Fusion.Scope<typeof(Fusion)>
	@param X Fusion.UsedAs<number>
	@param Y Fusion.UsedAs<number>
	@return Fusion.Computed<UDim2>
]=]
function Unit.UDim2Offset(
	Scope: Fusion.Scope<typeof(Fusion)>,
	X: Fusion.UsedAs<number>,
	Y: Fusion.UsedAs<number>
): Fusion.Computed<UDim2>
	return Unit.UDim2(Scope, 0, X, 0, Y)
end

--[=[
	@function UDim2Scale
	@within Util

	@param Scope Fusion.Scope<typeof(Fusion)>
	@param X Fusion.UsedAs<number>
	@param Y Fusion.UsedAs<number>
	@return Fusion.Computed<UDim2>
]=]
function Unit.UDim2Scale(
	Scope: Fusion.Scope<typeof(Fusion)>,
	X: Fusion.UsedAs<number>,
	Y: Fusion.UsedAs<number>
): Fusion.Computed<UDim2>
	return Unit.UDim2(Scope, X, 0, Y, 0)
end

--[=[
	@function Font
	@within Util

	@param Scope Fusion.Scope<typeof(Fusion)>
	@param X Fusion.UsedAs<number>
	@param Y Fusion.UsedAs<number>
	@return Fusion.Computed<UDim2>
]=]
function Unit.Font(
	Scope: Fusion.Scope<typeof(Fusion)>,
	Family: Fusion.UsedAs<string>,
	Weight: Fusion.UsedAs<Enum.FontWeight>?,
	Style: Fusion.UsedAs<Enum.FontStyle>?
): Fusion.Computed<UDim2>
	return Scope:Computed(function(Use)
		return Font.new(Use(Family), Use(Weight), Use(Style) or Enum.FontStyle.Normal)
	end)
end

return Unit
