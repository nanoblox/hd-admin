--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local commands: Task.Commands = {

    --------------------
	{
		name = "Respawn",
		aliases = {"Re"},
		args = {"Player"},
		cooldown = 10,
		run = function(task, args: {any})
			local player: Player = unpack(args)
			local loadCharacter = require(modules.PlayerUtil.loadCharacter)
			loadCharacter(player)
		end
	},

    --------------------
	{
		name = "Walkspeed",
		aliases = {"Speed"},
		undoAliases = {"Recover"},
		groups = {"WalkSpeed"},
		args = {"Player", "Number"},
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
		name = "Walkspeed2",
		aliases = {"Speed2"},
		groups = {"WalkSpeed"},
		args = {"Player", "Number"},
		run = function(task: Task.Class, args: {any})
			local target = args[1]
			local number = task:getOriginalArg("Number") or 250
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
}
return commands