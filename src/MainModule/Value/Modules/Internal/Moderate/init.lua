--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local TeleportService = game:GetService("TeleportService")
local commands: Task.Commands = {

    --------------------
	{
		name = "Mute",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			task:keep("UntilTargetLeaves")
			task.client:run(target)
		end
	},
	
    --------------------
	{
		name = "Kick",
		args = {"Player", "Text"},
		run = function(task: Task.Class, args: {any})
			local target, text = unpack(args)
			local targetName = target.Name
			local kickMessage = "by ".. targetName.."\n\nReason: '"..text.."'\n"
			if #text < 1 then
				kickMessage = "By: ".. targetName
			end
			target:Kick(kickMessage)
		end
	},

    --------------------
	{
		name = "Punish",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local target = unpack(args)
			local function updateChar()
				local char = target and target.Character
				if not char then return end
				char.Parent = nil
				task:onEnded(function()
					if char == target.Character then
						char.Parent = workspace
					else
						char:Destroy()
					end
				end)
			end
			task:keep("UntilTargetLeaves")
			task:redo(target, updateChar)
		end
	},

    --------------------
	{
		name = "Warn",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			Prompt.warn(task.caller, "Command Coming Soon")
		end
	},

    --------------------
	{
		name = "Follow",
		aliases	= {"Join", "JoinServer"},
		args = {"AnyUser"},
		run = function(task: Task.Class, args: {any})
			local userId = tonumber(unpack(args))
			local caller = task.caller
			if not userId or userId <= 0 then
				Prompt.error(caller, "Invalid User")
				return
			end
			local getNameFromUserIdAsync = require(modules.PlayerUtil.getNameFromUserIdAsync)
			local success, name = getNameFromUserIdAsync(userId)
			if not success or typeof(name) ~= "string" then
				name = tostring(userId)
			end
			Prompt.info(caller, `Teleporting to {name}...`)
			local success, errorMessage, _, placeId, jobId = pcall(function()
				return TeleportService:GetPlayerPlaceInstanceAsync(userId)
			end)
			if success and placeId and jobId then
				pcall(function()
					return TeleportService:TeleportToPlaceInstance(
						placeId,
						jobId,
						caller
					)
				end)
				-- In the future, can also listen out for TeleportEvent to confirm
				-- teleportation, or if not, to warn why it failed
				return
			end
			Prompt.error(caller, `Failed to teleport: {name} not in-game`)
		end
	},

    --------------------
	
}


return commands