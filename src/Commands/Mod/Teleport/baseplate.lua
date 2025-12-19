return function()
	local baseplate = Instance.new("Part")
	baseplate.Name = "Baseplate"
	baseplate.Anchored = true
	baseplate.BottomSurface = Enum.SurfaceType.Smooth
	baseplate.CFrame = CFrame.new(0, -8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	baseplate.Color = Color3.fromRGB(91, 91, 91)
	baseplate.Locked = true
	baseplate.Size = Vector3.new(2048, 16, 2048)
	baseplate.TopSurface = Enum.SurfaceType.Smooth

	local texture = Instance.new("Texture")
	texture.Name = "Texture"
	texture.Color3 = Color3.new()
	texture.ColorMap = "rbxassetid://6372755229"
	texture.Face = Enum.NormalId.Top
	texture.StudsPerTileU = 8
	texture.StudsPerTileV = 8
	texture.Texture = "rbxassetid://6372755229"
	texture.Transparency = 0.8
	texture.Parent = baseplate

	return baseplate
end