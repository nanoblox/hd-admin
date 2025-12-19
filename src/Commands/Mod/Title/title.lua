return function()
	local title = Instance.new("BillboardGui")
	title.Name = "Title"
	title.AlwaysOnTop = true
	title.Size = UDim2.fromScale(3, 1.5)
	title.StudsOffset = Vector3.new(0.5, 2.5999999046325684, 0)

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel.Position = UDim2.new(-0.17, -20, 0, 0)
	textLabel.Size = UDim2.new(1, 40, 0.9, -1)
	textLabel.Text = "Admin"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	textLabel.Parent = title

	return title
end