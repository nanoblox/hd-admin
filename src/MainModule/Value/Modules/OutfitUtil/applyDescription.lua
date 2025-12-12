--!strict
-- This collects changes and applies them all at once to avoid multiple ApplyDescription calls
-- It also makes it easy to build appearances from a 'base' appearance which
-- is especially useful for Outfit buffs
local OutfitUtil = require(script.Parent)
local deferringHumanoids = OutfitUtil.deferringHumanoids
local deferringHumanoidsComplete = OutfitUtil.deferringHumanoidsComplete
return function(humanoid: Humanoid?, baseDescription: HumanoidDescription? | any, properties: {[string]: any}?): HumanoidDescription?
	if typeof(humanoid) ~= "Instance" or not humanoid:IsA("Humanoid") then
		return nil
	end
	local collection = deferringHumanoids[humanoid]
	if collection then
		table.insert(collection.array, properties)
		return collection.baseDesc
	end
	local desc = baseDescription or humanoid:GetAppliedDescription() :: any
	if baseDescription then
		desc = desc:Clone()
	end
	collection = {array = {properties}, baseDesc = desc}
	deferringHumanoids[humanoid] = collection
	deferringHumanoidsComplete[humanoid] = collection
	task.defer(function()
		for _, otherProperties in collection.array do
			for pName, pValue in otherProperties :: any do
				desc[pName] = pValue
			end
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