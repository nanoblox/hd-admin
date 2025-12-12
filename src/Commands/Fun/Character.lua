--!strict
-- LOCAL
local ORDER = 60
local ROLES = {script.Parent.Name, "Character"}
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


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Size",
		groups = {"CharSize"},
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
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
		roles = ROLES,
		order = ORDER,
		args = {"Player", "Integer"},
		run = function(task: Task.Class, args: {any})
			local target, integer = unpack(args)
			local success, warningOrInfo = isTypeAsync(integer, Enum.AssetType.Head)
			if not success then
				success, warningOrInfo = isTypeAsync(integer, Enum.BundleType.DynamicHead)
				if not success then
					Prompt.warn(task.caller, warningOrInfo)
					return
				end
				integer = (warningOrInfo :: any).Id
			end
			task:keep("UntilTargetRespawns")
			task:buff(target, "Outfit", outfitBuff(target, {
				Head = integer,
			}))
		end
	},

    --------------------
	{
		name = "PotatoHead",
		aliases = {"PHead"},
		groups = {"HeadSize"},
		roles = ROLES,
		order = ORDER,
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
					applyDescription(humanoid, originalValue, {
						BackAccessory = 0,
						FaceAccessory = 0,
						FrontAccessory = 0,
						HairAccessory = 0,
						HatAccessory = 0,
						NeckAccessory = 0,
						ShouldersAccessory = 0,
						WaistAccessory  = 0,
					})
					task.spawn(function()
						humanoid.ApplyDescriptionFinished:Wait()
						humanoid:RemoveAccessories()
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
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Depth",
		aliases	= {"DScale", "DepthScale"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Height",
		aliases	= {"HScale", "HeightScale"};
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "HipHeight",
		aliases = {"Hip"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Shirt",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Pants",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Hat",
		aliases = {"Accessory"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "ClearHats",
		aliases	= {"ClrHats", "ClearAccessories", "ClrAccessories", "RemoveHats", "RemoveAccessories"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Become",
		aliases = {"Character", "Char"},
		args = {"Player", "AnyUser"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			--[[
			local target = args[1]
			local player = args[2]
			local getDescription = require(modules.PlayerUtil.getDescription)
            task:keep("UntilTargetRespawns")
            task:buff(target,"HumanoidDescription", function(hasEnded, originalValue: any)
                local humanoid = getHumanoid(target)
				local desc = getDescription(player)
				local appearance = if hasEnded then getDescription(target.userId) else desc
				if humanoid and appearance then
                    --humanoid:ApplyDescription(appearance)
                end
            end)
			--]]
		end
	},

    --------------------
	{
		name = "View",
		aliases	= {"Watch", "Spectate"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
}

return commands
