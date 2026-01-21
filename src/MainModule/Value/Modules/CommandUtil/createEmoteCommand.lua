--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local runEmoteId = require(modules.CommandUtil.runEmoteId)
local getTorso = require(modules.PlayerUtil.getTorso)
local getHRP = require(modules.PlayerUtil.getHRP)
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
local Remote = require(modules.Objects.Remote)
local playSoundInstance = Remote.new("PlaySoundInstance", "Event")


-- LOCAL FUNCTIONS
local function createTorsoSound(player: Player, soundId: number, details: {[string]: any}?, extra): Sound
	local properties: {[string]: any} = details or {}
	local hrp = getHRP(player)
	local volume = properties.Volume or 0.25
	local isLooped = properties.Looped == true
	local registerSound = require(modules.AssetUtil.registerSound)
	local torsoSound = registerSound(Instance.new("Sound"), "Command")
	torsoSound.Name = "HDTorsoSound"
	torsoSound.Volume = volume
	torsoSound.Looped = isLooped
	torsoSound.RollOffMaxDistance = 30
	torsoSound.RollOffMinDistance = 5
	torsoSound.SoundId = "rbxassetid://"..soundId
	torsoSound.Parent = hrp
	Instance.new("EqualizerSoundEffect", torsoSound)
	local startTime = properties.StartTime
	if startTime then
		torsoSound.TimePosition = startTime
	end
	if properties.LocalSoundId then
		playSoundInstance:fireClient(player, torsoSound)
	else
		torsoSound:Play()
	end
	return torsoSound
end

return function (originalEmoteName: string, emoteIdOrCallback: number | (...any) -> (...any), propertiesOrNil: {[string]: any}?)
	local topProperties: any = propertiesOrNil or {}
	local aliases = topProperties.Aliases
	local originalEmoteNameLower = originalEmoteName:lower()
	if topProperties.IsDance and not originalEmoteNameLower:match("dance") then
		-- This is to provide additional search function for dance-specific emotes
		if not aliases then
			aliases = {}
		end
		table.insert(aliases, originalEmoteName.."Dance")
	end
	local command: Task.Command = {
		name = originalEmoteName,
		aliases = aliases,
		groups = {"Emote"},
		args = {"Player", "AnimationSpeed"},
		run = function(task: Task.Class, args: {any})
			local emoteId = emoteIdOrCallback
			local properties = topProperties
			local emoteName = originalEmoteName
			if typeof(emoteIdOrCallback) == "function" then
				emoteName, emoteId, properties = emoteIdOrCallback()
			end
			local target, animationSpeed = unpack(args)
			local speed = (animationSpeed ~= 1 and animationSpeed) or properties.Speed or 1
			local janitor = task.janitor
			local localSoundId = properties.LocalSoundId
			local soundId = properties.SoundId or localSoundId
			local bundleId = tonumber(properties.BundleId)
			local isLooped = properties.Looped == true
			if properties.GroupExclusive == true then
				local checkWithinHDGroupAsync = require(modules.VerifyUtil.checkWithinHDGroupAsync)
				local caller = task.caller
				if caller and checkWithinHDGroupAsync(caller) == false then
					return
				end
			end
			if typeof(soundId) == "table" then
				soundId = soundId[math.random(1, #soundId :: any)]
			end
			if typeof(soundId) == "table" then
				local t = soundId
				for k, v in t do
					if k == "Id" then
						soundId = soundId.Id
					else
						properties[k] = v
					end
				end
			end
			local particles = properties.Particles
			if particles then
				local torso = getTorso(target)
				if torso and particles then
					for _, attachment in particles:GetChildren() do
						if attachment:IsA("Attachment") and attachment.Name:match("HD_") then
							local particleClone = janitor:add(attachment:Clone())
							particleClone.Parent = torso
						end
					end
				end
			end
			local character = target and target.Character
			local hrp = getHRP(target)
			if properties.Anchor and hrp then
				hrp.Anchored = true
				task:onEnded(function()
					if hrp.Parent then
						hrp.Anchored = false
					end
				end)
			end
			local bundleProperties = properties.BundleProperties
			local outfitBuff = require(modules.OutfitUtil.outfitBuff)
			if properties.ClearAccessories then
				task:buff(target, "Outfit", outfitBuff(target, {
					_ClearAccessories = true
				}))
			end
			if bundleId and character then
				local runBundleId = require(modules.OutfitUtil.runBundleId)
				runBundleId(task, bundleId, properties)
			end
			if bundleProperties then
				task:buff(target, "Outfit", outfitBuff(target, bundleProperties))
			end
			if properties.PlayVoice == true then
				local playTextToSpeech = require(modules.CommandUtil.playTextToSpeech)
				playTextToSpeech(target, emoteName)
			end
			if soundId then
				janitor:add(createTorsoSound(target, soundId, properties))
			end
			return runEmoteId(task, emoteId, speed, isLooped)
		end
	}
	return command
end