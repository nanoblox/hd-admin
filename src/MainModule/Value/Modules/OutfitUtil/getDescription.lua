--!strict
-- It's essential to use this in conjunction with OutfitUtil.applyDescription
-- to ensure that the humanoid retrieved reflects any potential deferred changes
local OutfitUtil = require(script.Parent)
local deferringHumanoids = OutfitUtil.deferringHumanoids
local deferringHumanoidsComplete = OutfitUtil.deferringHumanoidsComplete
return function(humanoid: Humanoid): HumanoidDescription
	local collection = deferringHumanoidsComplete[humanoid]
	if not collection then
		return humanoid:GetAppliedDescription()
	end
	local baseDescription = collection.baseDesc
	local desc = (baseDescription and baseDescription:Clone())
	for _, otherProperties in collection.array do
		for pName, pValue in otherProperties :: any do
			desc[pName] = pValue
		end
	end
	humanoid.Destroying:Once(function()
		desc:Destroy()
	end)
	return desc
end