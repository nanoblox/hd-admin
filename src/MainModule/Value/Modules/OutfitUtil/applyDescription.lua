--!strict
-- This collects changes and applies them all at once to avoid multiple ApplyDescription calls
-- It also makes it easy to build appearances from a 'base' appearance which
-- is especially useful for Outfit buffs
local OutfitUtil = require(script.Parent)
local deferringHumanoids = OutfitUtil.deferringHumanoids
local deferringHumanoidsComplete = OutfitUtil.deferringHumanoidsComplete
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local UIDCount = 0
return function(humanoid: Humanoid?, baseDescription: HumanoidDescription? | any, properties: {[string]: any}? | HumanoidDescription?): HumanoidDescription?
	if typeof(humanoid) ~= "Instance" or not humanoid:IsA("Humanoid") then
		return nil
	end
	if typeof(properties) == "Instance" and properties:IsA("HumanoidDescription") then
		local HumanoidDescription = require(modules.Serializer.Serializables.HumanoidDescription)
		local descProperties = HumanoidDescription.Template :: any
		local newAppearance: any = properties
		properties = {} :: any
		for propertyName, _ in descProperties do
			if properties[propertyName] then
				continue
			end
			properties[propertyName] = newAppearance[propertyName]
		end
		properties._Accessories = newAppearance:GetAccessories(true)
	end
	local function createBaseDesc(incomingDesc)
		if not incomingDesc:GetAttribute("BaseDescriptionUID") then
			UIDCount += 1
			incomingDesc:SetAttribute("BaseDescriptionUID", UIDCount)
		end
		return incomingDesc:Clone()
	end
	local collection = deferringHumanoids[humanoid]
	if collection then
		--[[
		if baseDescription then
			local currentBase = collection.baseDesc
			if not currentBase then
				collection.baseDesc = createBaseDesc(baseDescription)
			elseif currentBase:GetAttribute("BaseDescriptionUID") ~= baseDescription:GetAttribute("BaseDescriptionUID") then
				-- This is specifically for commands like ;become that input an
				-- entirely separate base description
				if not properties then
					properties = {}
				end
				local HumanoidDescription = require(modules.Serializer.Serializables.HumanoidDescription)
				local descProperties = HumanoidDescription.Template :: any
				properties = properties :: any
				for propertyName, _ in descProperties do
					if properties[propertyName] then
						continue
					end
					properties[propertyName] = baseDescription[propertyName]
				end
			end
		end --]]
		if properties then
			table.insert(collection.array, properties)
		end
		return collection.baseDesc
	end
	local desc = baseDescription or humanoid:GetAppliedDescription() :: any
	if baseDescription then
		desc = createBaseDesc(baseDescription)
	end
	collection = {array = {properties}, baseDesc = desc}
	deferringHumanoids[humanoid] = collection
	deferringHumanoidsComplete[humanoid] = collection
	task.defer(function()
		local accessories = desc:GetAccessories(false)
		local accessoryChanges = 0
		for _, otherProperties in collection.array do
			for pName, pValue in otherProperties :: any do
				if pName == "_Accessories" and type(pValue) == "table" then
					for _, accessoryInfo in pValue do
						accessoryChanges += 1
						table.insert(accessories, accessoryInfo)
					end
					continue
				elseif pName == "_ClearAccessories" and pValue == true then
					accessoryChanges += 1
					accessories = {}
					continue
				end
				desc[pName] = pValue
			end
		end
		if accessoryChanges > 0 then
			desc:SetAccessories(accessories, true)
		end
		deferringHumanoids[humanoid] = nil
		pcall(function()
			(humanoid :: any):ApplyDescription(desc, Enum.AssetTypeVerification.Always)
		end)
		deferringHumanoidsComplete[humanoid] = nil
		if baseDescription then
			desc:Destroy()
		end
	end)
	return desc
end