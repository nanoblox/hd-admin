--!strict
local ORDER = 220
local ROLE = "Ability"
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Lighting = game:GetService("Lighting")
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

	--------------------
	{
		name = "Speed",
		aliases = {"Walkspeed"},
		undoAliases = {"Recover"},
		groups = {"WalkSpeed"},
		args = {"Player", "Number"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 50
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local speed = if hasEnded then StarterPlayer.CharacterWalkSpeed else number
				if humanoid then
					humanoid.WalkSpeed = speed
				end
			end)
		end,
	},

	--------------------
	{
		name = "Fast",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local speed = if hasEnded then StarterPlayer.CharacterWalkSpeed else 100
				if humanoid then
					humanoid.WalkSpeed = speed
				end
			end)
		end
	},

	--------------------
	{
		name = "Slow",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "WalkSpeed", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local speed = if hasEnded then StarterPlayer.CharacterWalkSpeed else 10
				if humanoid then
					humanoid.WalkSpeed = speed
				end
			end)
		end
	},

	--------------------
	{
		name = "JumpHeight",
		args = {"Player","Number"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or StarterPlayer.CharacterJumpHeight
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local jump = if hasEnded then StarterPlayer.CharacterJumpHeight else number
				if humanoid then
					humanoid.JumpHeight = jump
				end
			end)
		end
	},

	--------------------
	{
		name = "SuperJump",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local jump = if hasEnded then StarterPlayer.CharacterJumpHeight else 50
				if humanoid then
					humanoid.JumpHeight = jump
				end
			end)
		end
	},

	--------------------
	{
		name = "HeavyJump",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			task:keep("UntilTargetRespawns")
			task:buff(target, "JumpHeight", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				local jump = if hasEnded then StarterPlayer.CharacterJumpHeight else 3
				if humanoid then
					humanoid.JumpHeight = jump
				end
			end)
		end
	},

	--------------------
	{
		name = "Health",
		args = {"Player","Number"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 100
			task:buff(target, "Health", function(hasEnded, isTop)
				local StarterPlayer = game:GetService("StarterPlayer")
				local humanoid = getHumanoid(target)
				if humanoid then
					humanoid.Health = number
					if number > humanoid.MaxHealth then
						humanoid.MaxHealth = number
					end
				end
			end)
		end
	},

	--------------------
	{
		name = "Heal",
		args = {"Player","Number"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 50
			local humanoid = getHumanoid(target)
			if humanoid then
				local processed = humanoid.Health+number
				humanoid.Health = processed
				task:destroy()
			end
		end
	},

	--------------------
	{
		name = "God",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local humanoid = getHumanoid(target)
			local oldHealth = humanoid.Health
			local oldMax = humanoid.MaxHealth
			task:keep("Indefinitely")
			task:buff(target, "Health", function(hasEnded, isTop)
				local humanoid = getHumanoid(target)
				if humanoid then
					humanoid.Health = math.huge
					humanoid.MaxHealth = math.huge
				end
			end)
			task:onEnded(function()
				humanoid.Health = oldHealth
				humanoid.MaxHealth = oldMax
			end)
		end
	},

	--------------------
	{
		name = "Damage",
		args = {"Player","Number"},
		roles = {ROLE},
		order = ORDER,
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 10
			local humanoid = getHumanoid(target)
			if humanoid then
				local processed = humanoid.Health-number
				humanoid.Health = processed
				task:destroy()
			end
		end
	},

	--------------------
	{
		name = "Kill",
		args = {"Player"},
		roles = {ROLE},
		order = ORDER,
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
