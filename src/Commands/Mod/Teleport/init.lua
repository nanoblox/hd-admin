--!strict
local ORDER = 340
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local teleportAsync = require(modules.PlayerUtil.teleportAsync)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local getHRP = require(modules.PlayerUtil.getHRP)
local commands: Task.Commands = {

    --------------------
	{
		name = "Teleport",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Bring",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "To",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Apparate",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

	--------------------
	{
		name = "Farland",
		args = {"Player"},
		credit = {"MiIoshiee", "ForeverHD"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local FARLAND_CFRAME = CFrame.new(5836480,683648,583648)
			local baseplate = task.janitor:add(require(script.baseplate)())
			baseplate.Name = "HDAdminFarlandBaseplate"
			baseplate.CFrame = FARLAND_CFRAME + Vector3.new(0, -10, 0)
			baseplate.Parent = workspace
			task.client:expose(target, baseplate)
			task:keep("UntilTargetRespawns")
			task:buff(target, "Teleport", function(hasEnded, originalValue: any, isFirst)
				local hrp = getHRP(target)
				local originalCFrame = if hrp then hrp.CFrame else CFrame.new(0, 0, 0)
				local targetCFrame = if hasEnded then originalValue else FARLAND_CFRAME
				teleportAsync(target, targetCFrame)
				return originalCFrame
			end)
		end
	},
	--------------------
}
	

return commands
