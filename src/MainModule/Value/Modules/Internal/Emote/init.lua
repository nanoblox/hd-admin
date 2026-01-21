--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local runEmoteId = require(modules.CommandUtil.runEmoteId)
local Prompt = require(modules.Prompt)


-- LOCAL FUNCTIONS
local function createCommand(emoteName: string, emoteId: number, properties: {[string]: any}?)
	if not properties then
		properties = {}
	end
	properties = properties :: {[string]: any}
	properties.PlayVoice = if properties.PlayVoice == false then false else true
	properties.Looped = true
	local createEmoteCommand = require(modules.CommandUtil.createEmoteCommand)
	local command = createEmoteCommand(emoteName, emoteId, properties)
	command.config = {EmoteDetail = {emoteName, emoteId, properties}}
	return command
end


-- COMMANDS
local commands: Task.Commands = {

    --------------------
	{
		name = "Emotes",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			local player = unpack(args)
			Prompt.info(player, "Coming Soon")
		end
	},

    --------------------
	{
		name = "Emote",
		groups = {"Emote"},
		args = {"Player", "EmoteIdOrName", "AnimationSpeed"},
		run = function(task: Task.Class, args: {any})
			local _, emoteIdOrName, animationSpeed = unpack(args)
			local Emotes = require(modules.Parent.Services.Emotes)
			local function getEmoteIdAsync(): (boolean, number | string)
				local numberEmoteId = tonumber(emoteIdOrName)
				local emote = numberEmoteId and Emotes.getEmoteById(numberEmoteId)
				if emote then
					return true, emote.emoteId
				end
				if emoteIdOrName == "" or emoteIdOrName == " " then
					local emote = Emotes.getRandomEmote()
					if emote then
						return true, emote.emoteId
					end
				end
				local emoteName = tostring(emoteIdOrName)
				emote = Emotes.getEmoteByName(emoteName, true)
				if emote then
					return true, emote.emoteId
				end
				if not numberEmoteId then
					return false, "Invalid EmoteId"
				end
				local isTypeAsync = require(modules.VerifyUtil.isTypeAsync)
				local success, warningOrInfo = isTypeAsync(numberEmoteId, Enum.AssetType.EmoteAnimation)
				if not success or typeof(warningOrInfo) ~= "table" then
					return false, tostring(warningOrInfo)
				end
				local name = warningOrInfo.Name
				local success, warning = Emotes.addEmoteAsync({emoteId = numberEmoteId, originalName = name})
				if not success then
					return false, tostring(warning)
				end
				return true, numberEmoteId
			end
			local success, emoteId = getEmoteIdAsync()
			if not success or typeof(emoteId) ~= "number" then
				Prompt.error(task.caller, `Emote Failed: {emoteId}`)
				return
			end
			runEmoteId(task, emoteId, animationSpeed, true)
		end
	},

    --------------------
	createCommand("Aura", 79795305221612, {Anchor = true, Particles = script.AuraParticles, LocalSoundId = 1836763934, Volume = 0.6}),
	createCommand("Helicopter", 110553756436163, {SoundId = 132629684548138, Volume = 0.25}),
	createCommand("Plane", 134913783169182, {SoundId = 72366538392902, Volume = 0.4}),
	createCommand("Tank", 85076031433488, {SoundId = 8213082259, Volume = 0.55}),
	createCommand("Car", 115407270129592, {SoundId = 5830439961, Volume = 0.8}),
	createCommand("RatDance", 83606297144428, {BundleId = 1598818, --[[BundleProperties = {HatAccessory = 140149417591336},--]] IsDance = true, GroupExclusive = true, LocalSoundId = 112903678064836, Volume = 0.8, StartTime = 18}),
	createCommand("CuteSit", 129668542320076, {PlayVoice = false}),
	createCommand("FakeDeath", 107498554725527, {BundleProperties = {Head = 76018488308272}, PlayVoice = false, SoundId = 79348298352567, Volume = 0.75, Looped = false}),
	createCommand("Hide", 84868707350198, {Looped = false, PlayVoice = false}),
	createCommand("Box", 73500261613116, {Looped = false, PlayVoice = false, SoundId = 85730811347567, Volume = 0.7}),
	createCommand("Dog", 84198855496510, {PlayVoice = false, SoundId = {4064828797, 4064874742, 4064885665}, Volume = 0.5, Looped = false}),
	createCommand("Worm", 108956933782219, {BundleId = 394523, SoundId = 9119560688, GroupExclusive = true, Volume = 0.3}),
	createCommand("TakeTheL", 75633408126191, {IsDance = true, LocalSoundId = 1840443935, Volume = 0.8, StartTime = 11.1}),
	createCommand("FryDance", 124799741487022, {ClearAccessories = true, IsDance = true, BundleProperties = {--[[Shirt = 887977581, Pants = 685516474, --]]Head = 15093053680, HatAccessory = 95980053615304}, Volume = 0.75, LocalSoundId = {{Id = 128809761213710, StartTime = 20.5}, 72920812093264, 135862064486942}}),
	createCommand("Phase", 79653736088166, {PlayVoice = false, SoundId = 9125516670, GroupExclusive = true, Volume = 0.4, Speed = 2}),
	--------------------
}


return commands