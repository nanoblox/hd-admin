--!strict
-- LOCAL
local ORDER = 260
local ROLES = {script.Parent.Name, "Character"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Players = game:GetService("Players")
local Character = require(script.Parent.Parent.Fun.Character)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)


-- LOCAL FUNCTIONS
local function getRigAsync(args: any, rigType: Enum.HumanoidRigType): (boolean, Model? | string)
	local target = unpack(args)
	local humanoid = getHumanoid(target)
	if not humanoid then
		return false, "You have no humanoid"
	end
	if humanoid.RigType == rigType then
		return false, `You're already {rigType.Name}!`
	end
	local char = target.Character
	local primaryPart = char and char.PrimaryPart
	if not primaryPart then
		return false, `Missing PrimaryPart`
	end
	local success, mainDesc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(target.CharacterAppearanceId)
	end)
	if not success then
		mainDesc:Destroy()
		return false, `You're already {mainDesc}!`
	end
	local rig = Players:CreateHumanoidModelFromDescription(mainDesc, rigType)
	mainDesc:Destroy()
	return true, rig
end

local function runRigCommand(task: Task.Class, args: any, rigType: Enum.HumanoidRigType)
	local target = unpack(args)
	local success, rig: (Model | string)? = getRigAsync(args, rigType)
	if not success or typeof(rig) ~= "Instance" then
		local caller = task.caller
		if caller == target then
			Prompt.warn(caller, tostring(rig))
		end
		return
	end
	local char = target.Character
	local primaryPart = char and char.PrimaryPart
	if not primaryPart then
		return
	end
	rig:SetPrimaryPartCFrame(primaryPart.CFrame)
	rig.Name = target.Name
	target.Character = rig
	rig.Parent = workspace
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "R15",
		roles = ROLES,
		order = ORDER,
		groups = {"RigType"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			runRigCommand(task, args, Enum.HumanoidRigType.R15)
		end
	},

    --------------------
	{
		name = "R6",
		roles = ROLES,
		order = ORDER,
		groups = {"RigType"},
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			runRigCommand(task, args, Enum.HumanoidRigType.R6)
		end
	},

    --------------------
	
}
return commands