--!strict
local ORDER = 300
local ROLES = {script.Parent.Name, "Fun"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Task = require(modules.Objects.Task)
local Prompt = require(modules.Prompt)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local activeSounds: {[Sound]: true} = {}
local commands: Task.Commands = {

    --------------------
	{
		name = "Music",
		aliases	= {"Sound", "Audio"},
		roles = ROLES,
		order = ORDER,
		args = {"Integer"},
		run = function(task: Task.Class, args: {any})
			local soundId = task:getOriginalArg("Integer") or 0
			local isTypeAsync = require(modules.VerifyUtil.isTypeAsync)
			local success, warningOrInfo = isTypeAsync(soundId, Enum.AssetType.Audio)
			if not success or typeof(warningOrInfo) ~= "table" then
				Prompt.warn(task.caller, "Invalid SoundType")
				return
			end
			local created = warningOrInfo.Created
			if created == "null" or not created then
				Prompt.warn(task.caller, "Invalid SoundId")
				return
			end
			local sound = Instance.new("Sound")
			task:keep("Indefinitely")
			activeSounds[sound] = true
			task.janitor:add(function()
				activeSounds[sound] = nil
				sound:Stop()
				sound:Destroy()
			end)
			sound.Looped = true
			sound.Name = "HDAdminSound"
			sound.Volume = 0.5
			sound.PlaybackSpeed = 1
			sound.SoundId = "rbxassetid://"..soundId
			sound.Parent = workspace
			sound:Play()
			for _, player in pairs(game:GetService("Players"):GetPlayers()) do
				Prompt.info(player, `Now playing '{warningOrInfo.Name}' ({soundId})`)
			end
		end
	},

    --------------------
	{
		name = "Pitch",
		aliases	= {"PlaybackSpeed"},
		roles = ROLES,
		order = ORDER,
		args = {"Number"},
		run = function(task: Task.Class, args: {any})
			local number = task:getOriginalArg("Number") or 1
			for sound, _ in activeSounds do
				sound.PlaybackSpeed = number
			end
		end
	},

    --------------------
	{
		name = "Volume",
		aliases	= {"Loudness"},
		roles = ROLES,
		order = ORDER,
		args = {"Number"},
		run = function(task: Task.Class, args: {any})
			local number = task:getOriginalArg("Number") or 1
			for sound, _ in activeSounds do
				sound.Volume = number
			end
		end
	},

    --------------------
	
}
return commands