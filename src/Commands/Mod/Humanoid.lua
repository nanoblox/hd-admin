--!strict
-- LOCAL
local ORDER = 220
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)


-- LOCAL FUNCTIONS
local function healthBuff(target: Player, number: number, hasEnded, originalValue: any)
	local humanoid = getHumanoid(target)
	local originalHealthDetails = if humanoid then {humanoid.Health, humanoid.MaxHealth} else {100, 100}
	local health = if hasEnded then originalValue[1] else number
	local currentMaxHealth = if humanoid then humanoid.MaxHealth else number
	local maxHealth = if hasEnded then originalValue[2] else math.max(number, currentMaxHealth)
	if humanoid then
		humanoid.Health = health
		humanoid.MaxHealth = maxHealth
	end
	return originalHealthDetails
end

local function humanoidBuff(target: Player, property: string, value: any, backupOriginalValue: any, hasEnded: boolean, originalValue: any)
	local humanoid = getHumanoid(target) :: any
	local originalPropertyValue = if humanoid then humanoid[property] else backupOriginalValue
	local newValue = if hasEnded then originalValue else value
	if humanoid then
		humanoid[property] = newValue
	end
	return originalPropertyValue
end


-- COMMANDS
local commands: Task.Commands = {

	--------------------
	{
		name = "Speed",
		aliases = {"WalkSpeed"},
		groups = {"WalkSpeed"},
		args = {"Player", "Number"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 50
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(...)
				print("... =", ...)
				return humanoidBuff(target, "WalkSpeed", number, StarterPlayer.CharacterWalkSpeed, ...)
			end)
		end,
	},

	--------------------
	{
		name = "Fast",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(...)
				return humanoidBuff(target, "WalkSpeed", 100, StarterPlayer.CharacterWalkSpeed, ...)
			end)
		end
	},

	--------------------
	{
		name = "Slow",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(...)
				return humanoidBuff(target, "WalkSpeed", 5, StarterPlayer.CharacterWalkSpeed, ...)
			end)
		end
	},

	--------------------
	{
		name = "JumpHeight",
		args = {"Player", "Number"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 50
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(...)
				return humanoidBuff(target, "JumpHeight", number, StarterPlayer.CharacterJumpHeight, ...)
			end)
		end
	},

	--------------------
	{
		name = "SuperJump",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(...)
				return humanoidBuff(target, "JumpHeight", 50, StarterPlayer.CharacterJumpHeight, ...)
			end)
		end
	},

	--------------------
	{
		name = "HeavyJump",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(...)
				return humanoidBuff(target, "JumpHeight", 3, StarterPlayer.CharacterJumpHeight, ...)
			end)
		end
	},

	--------------------
	{
		name = "Health",
		args = {"Player","Number"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 200
			task:buff(target, "Health", function(...)
				return healthBuff(target, number, ...)
			end)
		end
	},

	--------------------
	{
		name = "Heal",
		args = {"Player","Number"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local number = task:getOriginalArg("Number") or 50
			local humanoid = getHumanoid(target)
			if humanoid then
				humanoid.Health = humanoid.Health + number
			end
		end
	},

	--------------------
	{
		name = "God",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = math.huge
			task:keep("UntilTargetRespawns")
			task:buff(target, "Health", function(...)
				return healthBuff(target, number, ...)
			end)
		end
	},

	--------------------
	{
		name = "Damage",
		args = {"Player","Number"},
		roles = ROLES,
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 20
			local humanoid = getHumanoid(target)
			if humanoid then
				humanoid.Health = humanoid.Health - number
			end
		end
	},

	--------------------
	{
		name = "Kill",
		roles = ROLES,
		order = ORDER,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local humanoid = getHumanoid(target)
			if humanoid then
				humanoid.Health = 0
			end
		end
	},

	--------------------

}
return commands
