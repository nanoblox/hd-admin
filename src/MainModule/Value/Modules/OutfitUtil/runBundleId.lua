--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getDescription = require(modules.OutfitUtil.getDescription)
local applyDescription = require(modules.OutfitUtil.applyDescription)
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cachedWebsiteDescriptions: {[string]: HumanoidDescription} = {}
local cachedBundleDescriptions: {[string]: HumanoidDescription} = {}


-- LOCAL FUNCTIONS
local function getWebsiteDescriptionAsync(player: Player)
	local playerName = player.Name
	local char = player.Character
	local websiteDescription = cachedWebsiteDescriptions[playerName]
	if not websiteDescription then
		local success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(player.UserId)
		end)
		if not success then
			return false, result
		end
		websiteDescription = result
		cachedWebsiteDescriptions[playerName] = result
		player:GetPropertyChangedSignal("Parent"):Once(function()
			cachedWebsiteDescriptions[playerName] = nil
			result:Destroy()
		end)
	end
	return true, websiteDescription
end

local function getBundleDescriptionAsync(bundleId: number): (boolean, HumanoidDescription | string)
	local stringId = tostring(bundleId)
	local bundleDescription = cachedBundleDescriptions[stringId]
	if bundleDescription then
		return true, bundleDescription
	end
	local success, bundleDetails = pcall(function()
		return AssetService:GetBundleDetailsAsync(bundleId)
	end)
	if not success then
		return false, tostring(bundleDetails)
	end
	local bundleOutfitId
	for _, item in bundleDetails.Items do
		if item.Type == "UserOutfit" then
			bundleOutfitId = item.Id
			break
		end
	end
	if not bundleOutfitId then
		return false, "Missing Bundle Outfit"
	end
	local success, bundleDescription = pcall(function()
		return Players:GetHumanoidDescriptionFromOutfitId(bundleOutfitId)
	end)
	if not success or not bundleDescription then
		return false, tostring(bundleDescription)
	end
	cachedBundleDescriptions[stringId] = bundleDescription
	return true, bundleDescription
end

local function getFinalDescriptionAsync(player: Player, bundleId: number, properties: {[string]: any}?): (boolean, HumanoidDescription | string)
	local humanoid = getHumanoid(player)
	if humanoid then
		humanoid:UnequipTools()
	end
	local ignoreAccessories = properties and properties.IgnoreAccessories
	local ignoreAccessoriesDict = {}
	if typeof(ignoreAccessories) == "table" then
		for k, v in ignoreAccessories do
			ignoreAccessoriesDict[v] = true
		end
	end
	local ignoreBodyParts = properties and properties.IgnoreBodyParts
	local ignoreBodyPartsDict = {}
	if typeof(ignoreBodyParts) == "table" then
		for k, v in ignoreBodyParts do
			ignoreBodyPartsDict[v] = true
		end
	end
	local removeBodyParts = properties and properties.RemoveBodyParts
	local removeBodyPartsDict = {}
	if typeof(removeBodyParts) == "table" then
		for k, v in removeBodyParts do
			removeBodyPartsDict[v] = true
		end
	end
	local success, warningOrWebsiteDesc = getWebsiteDescriptionAsync(player)
	if not success or not warningOrWebsiteDesc then
		return false, tostring(warningOrWebsiteDesc)
	end
	local success, warningOrBundleDesc = getBundleDescriptionAsync(bundleId)
	if not success or typeof(warningOrBundleDesc) ~= "Instance" then
		return false, tostring(warningOrBundleDesc)
	end
	local bundleDescription = warningOrBundleDesc:Clone()
	for _, child in warningOrWebsiteDesc:GetChildren() do
		if child:IsA("AccessoryDescription") then
			local childAccName = child.AccessoryType.Name
			if ignoreAccessories ~= true and not ignoreAccessoriesDict[childAccName] then
				child:Clone().Parent = bundleDescription
			end
		elseif child:IsA("BodyPartDescription") then
			local bodyPartName = child.BodyPart.Name
			if ignoreBodyParts ~= true and not ignoreBodyPartsDict[bodyPartName] then
				local corresponding
				for _, descChild in bundleDescription:GetChildren() do
					if descChild:IsA("BodyPartDescription") and descChild.BodyPart == child.BodyPart then
						corresponding = descChild
					end
				end
				if not corresponding then
					child:Clone().Parent = bundleDescription
				else
					corresponding.Color = child.Color
				end
			end
			if removeBodyPartsDict[bodyPartName] then
				(bundleDescription :: any)[bodyPartName] = (warningOrWebsiteDesc :: any)[bodyPartName]
			end
		end
	end
	local KEEP = {
		"ClimbAnimation",
		"FallAnimation",
		"IdleAnimation",
		"JumpAnimation",
		"MoodAnimation",
		"RunAnimation",
		"SwimAnimation",
		"WalkAnimation",
		"GraphicTShirt",
		"Pants",
		"Shirt",
	}
	for _, prop in KEEP do
		(bundleDescription :: any)[prop] = (warningOrWebsiteDesc :: any)[prop]
	end
	local function splitByCapitals(str: string)
		str = str:gsub("(%u)", " %1")
		str = str:gsub("^%s", "")
		return str:split(" ")
	end
	if properties then
		for key, value in properties do
			if key:sub(1,5) == "Scale" then
				local scaleTypes = tostring(key:sub(6))
				local array = splitByCapitals(scaleTypes)
				for _, item in array do
					local prop = item.."Scale"
					(bundleDescription :: any)[prop] = value
				end
			end
		end
	end
	local char = player.Character
	local humanoid = getHumanoid(player)
	if not humanoid then
		return false, "Missing Humanoid"
	end
	return true, bundleDescription -- This must be forceFully destroyed after
end

local function runBundleId(task: Task.Class, bundleId: number, properties: {[string]: any}?)
	local aliases = if properties then properties.Aliases else nil
	local target = task.target :: Player
	if not target then
		Prompt.warn(task.caller, "No target player found.")
		return
	end
	local success, finalDesc = getFinalDescriptionAsync(target, bundleId, properties)
	if not success or typeof(finalDesc) ~= "Instance" then
		Prompt.warn(task.caller, tostring(finalDesc))
		return
	end
	task:keep("UntilTargetRespawns")
	task:buff(target, "Outfit", -10, function(hasEnded, originalValue: any)
		if hasEnded then
			finalDesc:Destroy()
		end
		local humanoid = getHumanoid(target)
		if not humanoid then return end
		local originalDescription = (originalValue or getDescription(humanoid)) :: any
		if hasEnded then
			applyDescription(humanoid, originalDescription)
		else
			applyDescription(humanoid, originalValue, finalDesc)
		end
		return originalDescription
	end)
end


return runBundleId