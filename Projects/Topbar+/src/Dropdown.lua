local contentProvider = game:GetService("ContentProvider")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local starterGui = game:GetService("StarterGui")
local HDAdmin = replicatedStorage:WaitForChild("HDAdmin")
local dropdown = {}
dropdown.__index = dropdown

function dropdown.new(icon,options)
	local self = {}
	setmetatable(self, dropdown)
	
	self.tempConnections = {}
	self.constConnections = {}
	self.icon = icon
	self.options = {}
	self.bringBackPlayerlist = false
	self.bringBackChat = false
	self.settings = {
		canHidePlayerlist = true,
		canHideChat = true,
		tweenSpeed = 0.2,
		easingDirection = Enum.EasingDirection.Out,
		easingStyle = Enum.EasingStyle.Quad,
		chatDefaultDisplayOrder = 6,
		backgroundColor = Color3.fromRGB(31, 33, 35),
		textColor = Color3.new(1,1,1),
		imageColor = Color3.new(1,1,1)
	}
	local preload = {}
	
	for i,optionData in ipairs(options) do
		local option = self:newOption(optionData,i)
		table.insert(preload,option.container.Icon)
	end
	
	table.insert(self.constConnections,self.icon.objects.button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local position = Vector2.new(input.Position.X,input.Position.Y)
			self:show(position)
		end
		input:Destroy()
	end))
	table.insert(self.constConnections,self.icon.objects.button.TouchLongPress:Connect(function(positions,state)
		if state == Enum.UserInputState.Begin then
			self:show()
		end
	end))
	
	spawn(function()
		contentProvider:PreloadAsync(preload)
	end)
	
	self:update()
	return self
end

function dropdown:update()
	local dropdownContainer = self.icon.objects.container.Parent.Parent.Dropdown
	
	if dropdownContainer.Visible then
		self:hide()
	end
	
	if not dropdownContainer then return end
	dropdownContainer.Background.BackgroundColor3 = self.settings.backgroundColor
	dropdownContainer.Background.BottomRoundedRect.ImageColor3 = self.settings.backgroundColor
	dropdownContainer.Background.TopRoundedRect.ImageColor3 = self.settings.backgroundColor
	for _,option in pairs(self.options) do
		option.container.TextLabel.TextColor3 = self.settings.textColor
		option.container.Icon.ImageColor3 = self.settings.imageColor
	end
	
	local isIcon = false
	for _,optionData in pairs(self.options) do
		if optionData.container.Icon.Image ~= "" then
			isIcon = true
		end
	end
	if isIcon then
		for _,optionData in pairs(self.options) do
			optionData.container.TextLabel.Position = UDim2.new(0.1,25,0.5,0)
		end
	else
		for _,optionData in pairs(self.options) do
			optionData.container.TextLabel.Position = UDim2.new(0,10,0.5,0)
		end
	end
end

function dropdown:set(setting,value)
	if self.settings[setting] then
		self.settings[setting] = value
	end
end

function dropdown:isOpen()
	if self.icon then
		return self.icon.objects.container.Parent.Parent.Dropdown.Visible
	end
	return false
end

function dropdown:hide()
	for _,connection in pairs(self.tempConnections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	if self.bringBackPlayerlist then
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true)
		self.bringBackPlayerlist = false
	end
	local dropdownContainer = self.icon.objects.container.Parent.Parent.Dropdown
	if self.bringBackChat then
		local chat = dropdownContainer.Parent.Parent:FindFirstChild("Chat")
		if chat then
			chat.DisplayOrder = self.settings.chatDefaultDisplayOrder
		end
	end
	dropdownContainer:TweenSize(
		UDim2.new(0.1,0,0,0),
		self.settings.easingDirection,
		self.settings.easingStyle,
		self.settings.tweenSpeed,
		true,
		function()
			if dropdownContainer.Size == UDim2.new(0.1,0,0,0) then
				dropdownContainer.Visible = false
			end
		end
	)
end

local function ToScale(offsetUDim2,viewportSize)
	return UDim2.new(offsetUDim2.X.Offset/viewportSize.X,0,offsetUDim2.Y.Offset/viewportSize.Y,0)
end

function dropdown:show(position)
	local dropdownContainer = self.icon.objects.container.Parent.Parent.Dropdown
	if dropdownContainer.Visible then self:hide() return end
	
	if position then
		dropdownContainer.Position = UDim2.new(0,position.X,0,math.clamp(position.Y+36,36,10000000))
	else
		dropdownContainer.Position = UDim2.new(0,self.icon.objects.container.AbsolutePosition.X,0,self.icon.objects.container.AbsolutePosition.Y+36+32)--topbar offset and icon size
	end
	
	if workspace.CurrentCamera then
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local position = UDim2.new(
			0,
			math.clamp(dropdownContainer.Position.X.Offset,0,viewportSize.X-dropdownContainer.AbsoluteSize.X-16),
			0,
			math.clamp(dropdownContainer.Position.Y.Offset,40,viewportSize.Y-dropdownContainer.AbsoluteSize.Y)
		)
		dropdownContainer.Position = ToScale(position,viewportSize)
	end
	
	for _,option in pairs(dropdownContainer:GetChildren()) do
		if option:IsA("Frame") and option.Name == "Option" then
			option.Visible = false
			option.Parent = script.Temp
		end
	end
	local containerSizeY = 8 --for top and bottom rounded rect
	local orderTable = {}
	
	for name,data in next, self.options do
		orderTable[data.data.order] = data
	end
	
	for i,data in ipairs(orderTable) do
		data.container.Parent = dropdownContainer
		data.container.Visible = true
		data.container.Position = UDim2.new(0,0,0,4+(35*data.data.order)-35)
		containerSizeY = containerSizeY + data.container.Size.Y.Offset
	end
	
	if self.settings.canHidePlayerlist and self.icon.rightSide and starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)
		self.bringBackPlayerlist = true
	end
	
	local chat = dropdownContainer.Parent.Parent:FindFirstChild("Chat")
	if chat and self.settings.canHideChat and dropdownContainer.Parent.DisplayOrder < chat.DisplayOrder then
		chat.DisplayOrder = dropdownContainer.Parent.DisplayOrder-1
		self.bringBackChat = true
	end
	
	self:update()
	
	if not userInputService.MouseEnabled and userInputService.TouchEnabled then
		local clickSound = dropdownContainer.Parent:FindFirstChild("ClickSound")
		if clickSound and clickSound.IsLoaded then
			clickSound.TimePosition = 0.1
			clickSound.Volume = 0.5
			clickSound:Play()
		else
			contentProvider:PreloadAsync({clickSound})
		end
	end
	
	dropdownContainer.Size = UDim2.new(0.1,0,0,0)
	dropdownContainer.Visible = true
	dropdownContainer:TweenSize(
		UDim2.new(0.1,0,0,containerSizeY),
		self.settings.easingDirection,
		self.settings.easingStyle,
		self.settings.tweenSpeed,
		true
	)
	
	local cancelCD = true
	delay(0.5,function()
		cancelCD = false
	end)
	
	table.insert(self.tempConnections,userInputService.InputBegan:Connect(function(input,gpe)
		if not cancelCD and (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.MouseButton2
		or input.UserInputType == Enum.UserInputType.MouseWheel
		or input.UserInputType == Enum.UserInputType.MouseButton3
		or input.UserInputType == Enum.UserInputType.Touch)
		then
			local isOn = false
			for i,v in pairs(dropdownContainer.Parent.Parent:GetGuiObjectsAtPosition(input.Position.X,input.Position.Y)) do
				if v:IsDescendantOf(dropdownContainer) then
					isOn = true
					break
				end
			end
			if not isOn then
				self:hide()
			end
		end
		input:Destroy()
	end))
	
	if userInputService.MouseEnabled and not runService:IsStudio() then
		table.insert(self.tempConnections,userInputService.WindowFocusReleased:Connect(function()
			self:hide()
		end))
	end
	
end

function dropdown:newOption(optionConfig,index)
	assert(not self.options[optionConfig.name],"There is already an option with that name")
	
	local optionContainer = Instance.new("Frame")
	optionContainer.Name = "Option"
	optionContainer.BackgroundColor3 = Color3.new(1,1,1)
	optionContainer.BackgroundTransparency = 1
	optionContainer.BorderSizePixel = 0
	optionContainer.Size = UDim2.new(1,0,0,35)
	optionContainer.Active = true
	optionContainer.Selectable = true
	optionContainer.ZIndex = 11
	optionContainer.Visible = false
	
	local optionIcon = Instance.new("ImageLabel")
	optionIcon.Name = "Icon"
	optionIcon.Image = optionConfig.icon or ""
	optionIcon.ScaleType = Enum.ScaleType.Fit
	optionIcon.BackgroundTransparency = 1
	optionIcon.AnchorPoint = Vector2.new(0.5,0.5)
	optionIcon.Position = UDim2.new(0.1,5,0.5,0)
	optionIcon.Size = UDim2.new(0,25,0,25)
	optionIcon.ZIndex = 12
	optionIcon.Parent = optionContainer
	
	local optionText = Instance.new("TextLabel")
	optionText.Text = optionConfig.name
	optionText.BackgroundTransparency = 1
	optionText.AnchorPoint = Vector2.new(0,0.5)
	optionText.Position = UDim2.new(0.1,25,0.5,0)
	optionText.Size = UDim2.new(1,-40,0,25)
	optionText.Font = Enum.Font.GothamSemibold
	optionText.TextScaled = true
	optionText.TextColor3 = Color3.new(1,1,1)
	optionText.ZIndex = 12
	optionText.TextXAlignment = Enum.TextXAlignment.Left
	optionText.Parent = optionContainer
	
	local uiText = Instance.new("UITextSizeConstraint")
	uiText.MaxTextSize = 18
	uiText.MinTextSize = 8
	uiText.Parent = optionText
	
	local option = {
		container = optionContainer,
		data = optionConfig,
	}
	
	optionContainer.MouseEnter:Connect(function()
		optionContainer.BackgroundTransparency = 0.9
	end)
	
	
	optionContainer.MouseLeave:Connect(function()
		optionContainer.BackgroundTransparency = 1
	end)
	
	optionContainer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			option.data.clicked()
			self:hide()
		end
		input:Destroy()
	end)
	
	optionContainer.TouchTap:Connect(function()
		option.data.clicked()
		self:hide()
	end)
	
	if index then
		optionConfig.order = index
	end
	
	if not optionConfig.order then
		option.data.order = 1
	end
	
	local firstOrder = option.data.order
	for name,data in next, self.options do
		if data.data.order == option.data.order then
			option.data.order = option.data.order + 1
			break
		end
	end
	for name,data in next, self.options do
		if data.data.order > firstOrder then
			data.data.order = data.data.order + 1
		end
	end
	
	self.options[optionConfig.name] = option
	optionContainer.Parent = script.Temp
	
	self:update()
	return option
end

function dropdown:removeOption(name)
	local option = self.options[name]
	if option then
		option.container:Destroy()
		option = nil
		self.options[name] = nil
	else
		warn("Could not find an option with that name.")
	end
	self:update()
end

function dropdown:destroy()
	self:hide()
	for i,v in pairs(self.options) do
		if v.container then
			v.container:Destroy()
		end
	end
	for i,v in pairs(self.constConnections) do
		if v.Connected then
			v:Disconnect()
		end
	end
	self = nil
end

return dropdown
