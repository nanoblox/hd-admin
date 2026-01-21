--!strict
-- LOCAL
local ORDER = 280
local ROLES = {script.Parent.Name, "Build"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHRP = require(modules.PlayerUtil.getHRP)
local Prompt = require(modules.Prompt)


-- LOCAL FUNCTIONS
local function createClone(character: Model?): (Model?, {[string]: AnimationTrack}?)
	if not character then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil
	end
		
	--Setup clone
	character.Archivable = true
	local clone = character:Clone()
	local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
	local specialChar = false
	if clone:FindFirstChild("Chest") then
		specialChar = true
	end
	clone.Name = character.Name.."'s HDAdminClone"
	for _, instance in pairs(clone:GetDescendants()) do
		local instanceParent = instance.Parent
		if instance:IsA("Humanoid") then
			instance.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		elseif instance:IsA("BillboardGui") then
			instance:Destroy()
		elseif instance:IsA("Weld") and instance.Part1 ~= nil and instanceParent and instanceParent:IsA("BasePart") then
			instance.Part0 = instanceParent
			local part1 = instance.Part1
			local part1Name = (part1 and part1.Name) or ""
			if clone:FindFirstChild(part1Name) then
				instance.Part1 = (clone :: any)[part1Name]
			elseif not specialChar then
				instance:Destroy()
			end
		end
	end
	
	--Make clone visible
	--module:SetTransparency(clone, 0)
	clone.Parent = workspace
	
	--Animations
	local tracks = {}
	local desc = humanoid:GetAppliedDescription()
	local animate = clone:FindFirstChild("Animate")
	if animate and cloneHumanoid then
		for _, instance in pairs(animate:GetChildren()) do
			local anim = (instance:GetChildren()[1])
			if anim and anim:IsA("Animation") then
				tracks[instance.Name] = cloneHumanoid:LoadAnimation(anim)
			end
		end
		tracks.idle:Play()
	end
	
	return clone, tracks
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "BuildingTools",
		aliases = {"BTools"}, 
		credit = {"GigsD4X"},
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local buildingTools = script.BuildingTools
			for _, tool in buildingTools:GetChildren() do
				-- Only load scripts within building tools once this command is executed to be doubly sure
				-- no vulerabilities accidentally work their way into HD Admin
				if not tool:IsA("Tool") then
					continue
				end
				local toolClone = tool:Clone()
				toolClone.Parent = target.Backpack
				for _, child in pairs(toolClone:GetDescendants()) do
					if child:IsA("Script") or child:IsA("LocalScript") then
						child.Enabled = true
					end
				end
			end
		end
	},

    --------------------
	{
		name = "Clone",
		roles = ROLES,
		order = ORDER,
		stackable = true,
		args = {"Players"},
		description = "Creates a physical animated clone of the target player(s). Use ;clear <caller> to remove.",
		run = function(task: Task.Class, args: {any})
			local poolOfTargets = unpack(args)
			if task:getOriginalArg("Players") == nil then
				local caller = task.caller
				poolOfTargets = {}
				if caller then
					table.insert(poolOfTargets, caller)
				end
			end
			for _, target in poolOfTargets do
				local char = target.Character
				local hrp = getHRP(target)
				if not hrp or not char then return end
				local janitor = task.janitor
				local clone, tracks = createClone(char)
				if not clone then
					Prompt.error(task.caller, "Failed to clone character")
					return
				end
				task:keep("UntilCallerLeaves")
				if clone and tracks then
					janitor:add(function()
						for _, track in tracks do
							track:Stop()
							track:Destroy()
						end
						clone:Destroy()
					end)
				end
				local humanoid = clone:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Subject
					humanoid.HealthDisplayDistance = 25
					humanoid.NameDisplayDistance = 25
				end
				local cloneHRP = clone:WaitForChild("HumanoidRootPart", 3)
				if cloneHRP and cloneHRP:IsA("BasePart") then
					cloneHRP.CFrame = hrp.CFrame * CFrame.new(0, 5, 0)
				end
				clone.Name = target.Name.."'s Clone"
				clone.Parent = workspace
				task.defer(function()
					local MAKE_DENSE = PhysicalProperties.new(99, 0.5, 1, 0.3, 1)
					for _, part in pairs(clone:GetChildren()) do
						if part:IsA("BasePart") then
							part.CustomPhysicalProperties = MAKE_DENSE
						end
					end
				end)
			end
		end
	},

    --------------------
	{
		name = "Clear",
		aliases = {"Clr"},
		roles = ROLES,
		order = ORDER,
		description = "Clears all tasks without a target from the caller. For player-specific, use ;reset <player>.",
		args = {"Caller"},
		run = function(task: Task.Class, args: {any})
			-- This clears all non-player specific tasks
			local callerToClear: Player = unpack(args)
			local tasks = Task.getTasksByCallerId(callerToClear.UserId) :: {Task.Class}
			local Commands = require(modules.Parent.Services.Commands)
			for _, targetTask: Task.Class in tasks do
				if not targetTask.target then
					targetTask:destroy()
				end
			end
		end
	},

    --------------------
	
}


return commands