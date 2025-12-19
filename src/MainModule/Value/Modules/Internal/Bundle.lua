--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local bundleCache = {}
local function createCommand(commandName: string, bundleId: number, properties)
	local command: Task.Command = {
		name = commandName,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local AssetService = game:GetService("AssetService")
			local desc: HumanoidDescription? = bundleCache[bundleId]
			local function applyDesc()
				if desc then

				end
			end
			if desc then
				return applyDesc()
			end
			local success, bundleDetails = pcall(function()
				return AssetService:GetBundleDetailsAsync(bundleId)
			end)
			if not success or not bundleDetails then
				Prompt.error(task.caller, `Failed to get bundle details for ID '{bundleId}': {bundleDetails})`)
				return
			end
			for _, item in next, bundleDetails.Items do
				if item.Type ~= "UserOutfit" then
					continue
				end
				success, desc = pcall(function()
					return Players:GetHumanoidDescriptionFromOutfitId(item.Id)
				end)
				if success and desc then
					bundleCache[bundleId] = desc
					break
				end
			end
			if not desc then
				Prompt.error(task.caller, `Failed to find bundle details for ID '{bundleId}'`)
				return
			end
			local humanoid = getHumanoid(target)
			if not humanoid then
				return
			end
			local newDescription = humanoid:GetAppliedDescription()
			local defaultDescription = Instance.new("HumanoidDescription")
			for _, property in next, {"BackAccessory", "BodyTypeScale", "ClimbAnimation", "DepthScale", "Face", "FaceAccessory", "FallAnimation", "FrontAccessory", "GraphicTShirt", "HairAccessory", "HatAccessory", "Head", "HeadColor", "HeadScale", "HeightScale", "IdleAnimation", "JumpAnimation", "LeftArm", "LeftArmColor", "LeftLeg", "LeftLegColor", "NeckAccessory", "Pants", "ProportionScale", "RightArm", "RightArmColor", "RightLeg", "RightLegColor", "RunAnimation", "Shirt", "ShouldersAccessory", "SwimAnimation", "Torso", "TorsoColor", "WaistAccessory", "WalkAnimation", "WidthScale"} do
				if HumanoidDescription[property] ~= defaultDescription[property] then -- property is not the default value
					newDescription[property] = HumanoidDescription[property]
				end
			end
			humanoid:ApplyDescription(newDescription, Enum.AssetTypeVerification.Always)
			--------------
		end
	}
	return command
end


local commands: Task.Commands = {

    --------------------
	{
		name = "Bundle",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	createCommand("Buffify", 594200, {RemoveBodyParts = {"Head"}}),
	createCommand("Wormify", 394523, {}),
	createCommand("Chibify", 6470, {}),
	createCommand("Plushify", 3416, {RemoveBodyParts = {"Head"}, ScaleHead = 1.15}),
	createCommand("Freakify", 1186597, {}),
	createCommand("Frogify", 386731, {}),
	createCommand("Spongify", 393419, {}),
	createCommand("Bigify", 455999, {}),
	createCommand("Creepify", 946396, {}),
	createCommand("Dinofy", 369985, {IgnoreAccessories = {"Hair"}}),
	createCommand("Fatify", 637696, {}),
	--------------------
}

return commands