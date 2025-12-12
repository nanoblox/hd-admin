local function createFakeBodyPart(character, bodyPart)
	local partName = bodyPart.Name
	local partParent = bodyPart.Parent
	local isAccessory = partParent and partParent:IsA("Accessory")
	if isAccessory then
		local handleName = partParent:GetAttribute("HDPartName")
		if not handleName then
			handleName = "Handle"..math.random(1,10000)..partParent.Name
			partParent:SetAttribute("HDPartName", handleName)
		end
		partName = handleName
	end
	local fakePartName = "Fake"..partName
	local fakePart = character:FindFirstChild(fakePartName)
	if fakePart then
		fakePart:SetAttribute("DisableMorphPart", true)
		fakePart:Destroy()
		fakePart = nil
	end
	local destroySpecialMesh = false
	local specialMesh = bodyPart:FindFirstChildOfClass("SpecialMesh")
	local keepSpecialMesh = false
	local partNameWithoutSpaces = partName:gsub(" ","")
	for _, item in pairs(character:GetChildren()) do
		-- This helps find the mesh part for R6 characters
		if item:IsA("CharacterMesh") then
			local bodyPartName = item.BodyPart.Name
			if partNameWithoutSpaces:match(bodyPartName) then
				specialMesh = Instance.new("SpecialMesh")
				specialMesh.MeshId = "rbxassetid://"..item.MeshId
				destroySpecialMesh = true
			end
		end
	end
	if specialMesh then
		local meshId = specialMesh.MeshId
		if not meshId or meshId =="" or meshId == " " then
			-- This is for R6 characters with standard (not emotable) heads
			keepSpecialMesh = true
		else
			local InsertService = game:GetService("InsertService")
			local success, insertedFakePart = pcall(function()
				return InsertService:CreateMeshPartAsync(meshId, Enum.CollisionFidelity.Default, Enum.RenderFidelity.Automatic)
			end)
			if success and insertedFakePart then
				local scale = specialMesh.Scale
				fakePart = insertedFakePart
				fakePart.Size *= scale
				fakePart.CFrame = bodyPart.CFrame
			end
		end
		if destroySpecialMesh then
			specialMesh:Destroy()
		end
	end
	if not fakePart then
		fakePart = bodyPart:Clone()
	end
	for _, child in pairs(fakePart:GetChildren()) do
		if child:IsA("WrapLayer") then
			child.Order -= 20
		elseif not (child.Name == "OriginalSize" and child:IsA("Vector3Value")) then
			child:Destroy()
		end
	end
	if keepSpecialMesh then
		specialMesh:Clone().Parent = fakePart
	end
	fakePart.CanCollide = false
	fakePart.CanTouch = false
	if fakePart:IsA("MeshPart") then
		fakePart.TextureID = ""
	end
	fakePart.Name = "Fake"..partName
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = fakePart
	weld.Part1 = bodyPart
	weld.Parent = fakePart
	bodyPart.Transparency = 1
	local connections = {}
	local head = character:FindFirstChild("Head")
	local partToListen = if isAccessory and head then head else bodyPart
	fakePart.Color = partToListen.Color
	fakePart.Parent = character
	table.insert(connections, partToListen:GetPropertyChangedSignal("Color"):Once(function()
		fakePart.Color = partToListen.Color
	end))
	fakePart.Destroying:Once(function()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end)
	return fakePart
end

local function clearFakeBodyParts(character)
	for a,b in pairs(character:GetDescendants()) do
		if b:IsA("BasePart") then
			if string.sub(b.Name, 1, 4) == "Fake" then
				b:SetAttribute("DisableMorphPart", true)
				b:Destroy()
			elseif b.Name ~= "HumanoidRootPart" then
				b.Transparency = 0
			end
		end
	end
end

local function setFakePart(char, info, part)
	task.defer(function()
		local partName = part.Name
		local fakePart = createFakeBodyPart(char, part)
		local connections = {}
		local function cleanup()
			for _, connection in pairs(connections) do
				connection:Disconnect()
			end
			fakePart:Destroy()
			if fakePart:GetAttribute("DisableMorphPart") then
				return
			end
			local newPart = char:WaitForChild(partName, 4)
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if newPart and char.Parent and humanoid and humanoid.Health > 0 then
				setFakePart(char, info, newPart)
			end
		end
		table.insert(connections, part.Destroying:Once(cleanup))
		table.insert(connections, part:GetPropertyChangedSignal("Size"):Once(cleanup))
		for pName, pValue in pairs(info) do
			if pName == "Material" then
				fakePart.Material = pValue
				if pValue == Enum.Material.Glass then
					fakePart.Transparency = 0.5
				else
					fakePart.Transparency = 0
				end
			elseif pName == "Reflectance" then
				fakePart.Reflectance = pValue
			elseif pName == "Transparency" then
				fakePart.Transparency = pValue
			elseif pName == "Color" then
				fakePart.Color = pValue
			end
		end
	end)
end

local function checkBodyPart(part: BasePart)
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.sub(part.Name,1,4) ~= "Fake" then
		return true
	else
		return false
	end
end

local function setFakeBodyParts(char: Model, info: {[string]: any})
	if not char then return end
	for a,b in pairs(char:GetDescendants()) do
		local itemParent = b.Parent
		if (itemParent == char or (itemParent and itemParent:IsA("Accessory"))) and checkBodyPart(b) then
			setFakePart(char, info, b)
		end
	end
end

return setFakeBodyParts