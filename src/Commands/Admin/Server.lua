--!strict
local ORDER = 420
local ROLES = {script.Parent.Name, "Moderate"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local Prompt = require(modules.Prompt)
local Players = game:GetService("Players")
local commands: Task.Commands = {

    --------------------
	{
		name = "Shutdown",
		roles = ROLES,
		order = ORDER,
		args = {},
		cooldown = 10,
		run = function(task: Task.Class, args: {any})
			local getNameFromUserIdAsync = require(modules.PlayerUtil.getNameFromUserIdAsync)
			local callerId = task.callerUserId
			local success, callerNameOrWarning = getNameFromUserIdAsync(callerId)
			local callerName = if success then callerNameOrWarning else "Server"
			local kickMessage = `The server has been shutdown by {callerName}`
			for _, player in Players:GetPlayers() do
				Prompt.message(player, "Shutting down server...", {
					title = "Server Shutdown",
					fromUserId = callerId,
				})
			end
			task:keep("Indefinitely")
			task.wait(3)
			for _, player in Players:GetPlayers() do
				player:Kick(kickMessage)
			end
			Players.PlayerAdded:Connect(function(player)
				player:Kick(kickMessage)
			end)
		end
	},

    --------------------
	{
		name = "LockServer",
		aliases = {"ServerLock", "SLock"},
		undoAliases = {"OpenServer"},
		roles = ROLES,
		order = ORDER,
		args = {"Role"},
		run = function(task: Task.Class, args: {any})
			local role = unpack(args)
			local roleName = role and role.name
			local callerRoleIsLowerThanGiven = false -- RoleService HERE
			if callerRoleIsLowerThanGiven then
				Prompt.warn(task.caller, `Cannot use role '{roleName}' as your highest owned one is below`)
				return
			end
			local function getMessage(lockStatus: string, ignoreRole: boolean?)
				local newMessage = `The server has been {lockStatus}`
				if roleName and ignoreRole ~= true then
					newMessage = newMessage .. ` for ranks below '{roleName}'`
				end
				return newMessage
			end
			task:keep("Indefinitely")
			local initialMessage = getMessage("locked")
			for _, player in Players:GetPlayers() do
				Prompt.hint(player, initialMessage)
			end
			task:onEndedForGood(function()
				local endMessage = getMessage("unlocked", true)
				for _, player in Players:GetPlayers() do
					Prompt.hint(player, endMessage)
				end
			end)
			local function checkToKickPlayer(player: Player, isNewPlayer: boolean?)
				local hasRoleEqualOrAbove = true -- RoleService HERE
				if hasRoleEqualOrAbove then
					return
				end
				local kickMessage = `The server is locked`
				if roleName then
					kickMessage = kickMessage..` for ranks below '{roleName}'`
				end
				player:Kick(kickMessage)
				for _, player in Players:GetPlayers() do
					Prompt.hint(player, `Server Lock: {player.Name} attempted to join`)
				end
			end
			task.janitor:add(Players.PlayerAdded:Connect(function(player: Player)
				checkToKickPlayer(player, true)
			end))
		end
	},

    --------------------
	
}
return commands