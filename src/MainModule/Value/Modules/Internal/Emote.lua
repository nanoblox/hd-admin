--!strict
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Task = require(modules.Objects.Task)
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
local function createCommand(commandName, properties)
	local command: Task.Command = {
		name = commandName,
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			-- Implementation of the emote command using properties
		end
	}
	return command
end


local commands: Task.Commands = {

    --------------------
	{
		name = "Emotes",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	{
		name = "Emote",
		args = {"Player"},
		run = function(task: Task.Class, args: {any})
			
		end
	},

    --------------------
	createCommand("Aura", {emoteId = 79795305221612, anchor = true, particles = "AuraParticles", localSoundId = 1836763934, volume = 0.6}),
	createCommand("Helicopter", {emoteId = 110553756436163, soundId = 132629684548138, volume = 0.25}),
	createCommand("Plane", {emoteId = 134913783169182, soundId = 72366538392902, volume = 0.4}),
	createCommand("Tank", {emoteId = 85076031433488, soundId = 8213082259, volume = 0.55}),
	createCommand("Car", {emoteId = 115407270129592, soundId = 5830439961, volume = 0.8}),
	createCommand("RatDance", {emoteId = 83606297144428, bundleId = 1598818, --[[bundleProperties = {HatAccessory = 140149417591336},--]] isDance = true, localSoundId = 112903678064836, volume = 0.8, startTime = 18}),
	createCommand("CuteSit", {emoteId = 129668542320076, ignoreVoice = true}),
	createCommand("FakeDeath", {bundleProperties = {Head = 76018488308272}, emoteId = 107498554725527, ignoreVoice = true, soundId = 79348298352567, volume = 0.75, playOnce = true}),
	createCommand("Hide", {emoteId = 84868707350198, playOnce = true, ignoreVoice = true}),
	createCommand("Box", {emoteId = 73500261613116, playOnce = true, ignoreVoice = true, soundId = 85730811347567, volume = 0.7}),
	createCommand("Dog", {emoteId = 84198855496510, ignoreVoice = true, soundId = {4064828797, 4064874742, 4064885665}, volume = 0.5, playOnce = true}),
	createCommand("Worm", {emoteId = 108956933782219, bundleId = 394523, soundId = 9119560688, volume = 0.3}),
	createCommand("TakeTheL", {emoteId = 75633408126191, isDance = true, localSoundId = 1840443935, volume = 0.8, startTime = 11.1}),
	createCommand("FryDance", {clearAccessories = true, isDance = true, bundleProperties = {--[[Shirt = 887977581, Pants = 685516474, --]]Head = 15093053680, HatAccessory = 95980053615304}, emoteId = 124799741487022, volume = 0.75, localSoundId = {{id = 128809761213710, startTime = 20.5}, 72920812093264, 135667903253566, 135862064486942}}),
	createCommand("Phase", {emoteId = 79653736088166, ignoreVoice = true, soundId = 9125516670, volume = 0.4, speed = 2}),
	--------------------
}

return commands