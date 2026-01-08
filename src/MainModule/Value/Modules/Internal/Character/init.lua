--!strict
-- LOCAL
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Prompt = require(modules.Prompt)
local MarketplaceService = game:GetService("MarketplaceService")
local getNeck = require(modules.PlayerUtil.getNeck)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local applyDescription = require(modules.OutfitUtil.applyDescription)
local getDescription = require(modules.OutfitUtil.getDescription)
local getHead = require(modules.PlayerUtil.getHead)
local isTypeAsync = require(modules.VerifyUtil.isTypeAsync)


-- LOCAL FUNCTIONS
local function outfitBuff(target, properties: {[string]: any})
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

local function getAccessoryTypeAsync(integer)
	if integer <= 0 then
		return false, "Invalid accessoryID"
	end
	local MarketplaceService = game:GetService("MarketplaceService")
	local success, productInfo = pcall(function()
		return (MarketplaceService :: any):GetProductInfo(integer, Enum.InfoType.Asset)
	end)
	if not success then
		return false, tostring(productInfo)
	end
	local assetTypeId = tonumber(productInfo.AssetTypeId)
	if not assetTypeId then
		return false, "Invalid accessoryType"
	end
	local assetEnum = Enum.AssetType:FromValue(assetTypeId)
	local enumName = (assetEnum and assetEnum.Name) or ""
	local isHat = enumName == "Hat"
	if not (enumName:match("Accessory") or isHat) then
		return false, "Invalid accessory"
	end
	local function stipStringOfAccessory(s: string): string
		if type(s) ~= "string" then return s end
		local suffix = "Accessory"
		if #s >= #suffix and string.sub(s, -#suffix) == suffix then
			return string.sub(s, 1, #s - #suffix)
		end
		return s
	end
	local accessoryTypeName = if isHat then enumName else stipStringOfAccessory(enumName)
	local accessoryType = (Enum.AccessoryType :: any)[accessoryTypeName]
	if not accessoryType then
		return false, "Invalid accessory type enum"
	end
	return true, accessoryType
end

local function getClearHatsProperties()
	local properties = {
		["_ClearAccessories"] = true,
	}
	return properties :: {[string]: any}
end

local function getRunFromAccessoryCommand(name: string, validTypes: {[Enum.AccessoryType]: true})
	return function(task: Task.Class, args: {any})
		local target, integer = unpack(args)
		local success, warning = isTypeAsync(integer, (Enum.AssetType :: any)[name])
		if not success then
			local success, accessoryTypeEnum: any = getAccessoryTypeAsync(integer)
			if not success or not validTypes[accessoryTypeEnum] then
				Prompt.warn(task.caller, `AssetId is not a {name}`)
				return
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				["_Accessories"] = {
					{
						AssetId = integer,
						AccessoryType = accessoryTypeEnum,
						Order = 1,
					},
				}
			}))
			return
		end
		task:keep("UntilTargetRespawns")
		task:buff(target, "Outfit", outfitBuff(target, {
			[name] = integer,
		}))
	end
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Size",
		groups = {"CharSize"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 1.5
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				DepthScale = 1*scale,
				HeightScale = 1*scale,
				WidthScale = 1*scale,
				HeadScale = 1*scale,
			}))
		end
	},

    --------------------
	{
		name = "HeadSize",
		aliases = {"HeadScale"},
		groups = {"HeadSize"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 2
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				HeadScale = 1*scale,
			}))
		end
	},

    --------------------
	{
		name = "BigHead",
		aliases = {"BHead", "LargeHead"},
		groups = {"HeadSize"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				HeadScale = 2.5,
			}))
		end
	},

    --------------------
	{
		name = "SmallHead",
		groups = {"SHead", "HeadSize"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				HeadScale = 0.6,
			}))
		end
	},

    --------------------
	{
		name = "Dwarf",
		groups = {"HeadSize", "CharSize"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = 1
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				DepthScale = 0.75*scale,
				HeightScale = 0.5*scale,
				WidthScale = 0.75*scale,
				HeadScale = 1.4*scale,
			}))
		end
	},

    --------------------
	{
		name = "GiantDwarf",
		groups = {"HeadSize", "CharSize"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = 3
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				DepthScale = 0.75*scale,
				HeightScale = 0.5*scale,
				WidthScale = 0.65*scale,
				HeadScale = 1.4*scale,
			}))
		end
	},

    --------------------
	{
		name = "Squash",
		aliases	= {"Flat", "Flatten"};
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				HeightScale = 0.1,
				HeadScale = 0.5,
			}))
		end
	},

    --------------------
	{
		name = "Width",
		aliases	= {"WScale", "WidthScale"};
		groups = {"CharWidth"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Scale") or 2
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				WidthScale = number,
			}))
		end
	},

    --------------------
	{
		name = "Fat",
		groups = {"CharWidth"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				WidthScale = 2,
				DepthScale = 1.5,
			}))
		end
	},

    --------------------
	{
		name = "Thin",
		aliases = {"Skinny"},
		groups = {"CharWidth"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				WidthScale = 0.2,
				DepthScale = 0.2,
			}))
		end
	},

    --------------------
	{
		name = "Face",
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			local success, warning = isTypeAsync(integer, Enum.AssetType.Face)
			if not success then
				Prompt.warn(task.caller, warning)
				return
			end
			local head = getHead(target)
			local headId = nil
			if not head or not head:FindFirstChild("face") then
				headId = 0
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				Head = headId,
				Face = integer,
			}))
		end
	},

    --------------------
	{
		name = "Head",
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			local function getHeadIdAsync()
				local success, warningOrInfo = isTypeAsync(integer, Enum.AssetType.Head)
				if success then
					return true, integer
				end
				success, warningOrInfo = isTypeAsync(integer, Enum.AssetType.DynamicHead)
				if success then
					return true, integer
				end
				success, warningOrInfo = isTypeAsync(integer, Enum.BundleType.DynamicHead)
				if not success then
					return false, warningOrInfo
				end
				local items = (warningOrInfo :: any).Items
				if items then
					for _, item in items do
						if item.Name:match("Dynamic Head") then
							return true, item.Id
						end
					end
				end
				return false, "No DynamicHead found"
			end
			local success, headId = getHeadIdAsync()
			if not success then
				Prompt.warn(task.caller, headId)
				return
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				Head = headId,
			}))
		end
	},

    --------------------
	{
		name = "PotatoHead",
		aliases = {"PHead"},
		groups = {"HeadSize"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				Head = 14917727535,
				HeadScale = 3,
			}))
			task:buff(target, "Outfit", function(hasEnded, originalValue: any)
				local humanoid = getHumanoid(target)
				if not humanoid then return end
				local originalDescription = (originalValue or getDescription(humanoid)) :: any
				if hasEnded then
					applyDescription(humanoid, originalDescription)
				else
					local clearProperties = getClearHatsProperties()
					applyDescription(humanoid, originalValue, clearProperties)
					task.spawn(function()
						humanoid.ApplyDescriptionFinished:Wait()
						local neck = getNeck(target)
						if neck then
							neck.C0 *= CFrame.Angles(0, 0, math.rad(90)) * CFrame.new(0.5, -0.9, 0)
						end
					end)
				end
				return originalDescription
			end)
		end
	},

    --------------------
	{
		name = "BodyTypeScale",
		aliases = {"BTScale"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 0.5
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				BodyTypeScale = scale,
			}))
		end
	},

    --------------------
	{
		name = "Depth",
		aliases	= {"DScale", "DepthScale"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 2
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				DepthScale = scale,
			}))
		end
	},

    --------------------
	{
		name = "Height",
		aliases	= {"HScale", "HeightScale"};
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 2
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				HeightScale = scale,
			}))
		end
	},

    --------------------
	{
		name = "HipHeight",
		aliases = {"Hip"},
		args = {"Player", "Scale"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local scale = task:getOriginalArg("Scale") or 2
			local humanoid = getHumanoid(target)
			if not humanoid then return end
			local original = humanoid.HipHeight
			task:keep("UntilTargetRespawns")
			humanoid.HipHeight = scale
			task:onEnded(function()
				humanoid.HipHeight = original
			end)
		end
	},

    --------------------
	{
		name = "Shirt",
		stackable = true,
		args = {"Player", "Integer"},
		run = getRunFromAccessoryCommand("Shirt", {
			[Enum.AccessoryType.Shirt] = true,
			[Enum.AccessoryType.Jacket] = true,
			[Enum.AccessoryType.Sweater] = true,
			[Enum.AccessoryType.TShirt] = true,
		}),
	},

    --------------------
	{
		name = "Pants",
		stackable = true,
		args = {"Player", "Integer"},
		run = getRunFromAccessoryCommand("Pants", {
			[Enum.AccessoryType.Pants] = true,
			[Enum.AccessoryType.DressSkirt] = true,
			[Enum.AccessoryType.Waist] = true,
		}),
	},

    --------------------
	{
		name = "Accessory",
		aliases = {"Hair", "Hat"},
		stackable = true,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			local success, accessoryTypeEnum = getAccessoryTypeAsync(integer)
			if not success then
				Prompt.warn(task.caller, accessoryTypeEnum)
				return
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				["_Accessories"] = {
					{
						AssetId = integer,
						AccessoryType = accessoryTypeEnum,
					},
				}
			}))
		end
	},

    --------------------
	{
		name = "ClearHats",
		aliases	= {"ClrHats", "ClearAccessories", "ClrAccessories", "RemoveHats", "RemoveAccessories"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local clearProperties = getClearHatsProperties()
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, clearProperties))
		end
	},

    --------------------
	{
		name = "Char",
		aliases = {"Character", "Become"},
		args = {"OptionalPlayer", "AnyUser"},
		run = function(task: Task.Class, args: {any})
			print("CHAR COMMAND args =", args)
			local target = unpack(args)
			local userId = task:getOriginalArg("AnyUser") or 1
			local Players = game:GetService("Players")
			local success, newDescription = pcall(function()
				return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
			end)
			print("userId, target =", userId, target, typeof(userId))
			print("success, newDescription =", success, newDescription)
			if not success then
				Prompt.warn(task.caller, tostring(newDescription))
				return
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", function(hasEnded, originalValue: any)
				local humanoid = getHumanoid(target)
				if not humanoid then return end
				local originalDescription = (originalValue or getDescription(humanoid)) :: any
				if hasEnded then
					applyDescription(humanoid, originalDescription)
				else
					applyDescription(humanoid, originalValue, newDescription)
				end
				return originalDescription
			end)
		end
	},

    --------------------
	{
		name = "View",
		aliases	= {"Watch", "Spectate"},
		args = {"SinglePlayer"},
		run = function(task: Task.Class, args: {any})
			local playerToView = unpack(args)
			local caller = task.caller
			print("playerToView =", playerToView)
			if not playerToView or not caller then return end
			if caller == playerToView then return end
			task:keep("UntilCallerLeaves")
			task:keep("UntilTargetLeaves")
			task.client:run(caller, playerToView)
		end
	},

    --------------------
}

return commands
