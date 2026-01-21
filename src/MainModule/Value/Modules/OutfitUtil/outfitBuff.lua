--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getDescription = require(modules.OutfitUtil.getDescription)
local applyDescription = require(modules.OutfitUtil.applyDescription)
return function (target, properties: {[string]: any})
	return function(hasEnded, originalValue: any)
		local humanoid = getHumanoid(target)
		if not humanoid then return end
		local char = target.Character
		local originalDescription = (originalValue or getDescription(humanoid)) :: any
		if hasEnded then
			applyDescription(humanoid, originalDescription)
		else
			applyDescription(humanoid, originalValue, properties)
		end
		return originalDescription
	end
end