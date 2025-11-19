-- Handlers for different sound settings
local SETTINGS_KEY = "YouSettings"
local SOUND_KEY = "Sound"
local HANDLERS = {
	["Volume"] = function(soundGroup: SoundGroup, value: number)
		soundGroup.Volume = value
	end,
	["Pitch"] = function(soundGroup: SoundGroup, value: number)
		local pitchShifter = soundGroup:FindFirstChildWhichIsA("PitchShiftSoundEffect")
		if not pitchShifter then
			pitchShifter = Instance.new("PitchShiftSoundEffect")
			pitchShifter.Parent = soundGroup
		end
		pitchShifter.Enabled = value <= 0.99 or value >= 1.01
		pitchShifter.Octave = value
	end,
}

-- Types
export type SoundType = "Music" | "Command" | "Interface"

-- Local
local TAG = "HDAdminSound"
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local isClient = RunService:IsClient()
local isServer = not isClient
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local CollectionService = game:GetService("CollectionService")

-- If is server, setup the initial container
if isServer then
	local function createGroup(name, parent)
		local soundGroup = parent:FindFirstChild(name)
		if soundGroup then
			return soundGroup
		end
		soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = name
		soundGroup.Parent = parent
		return soundGroup
	end
	local audio = Instance.new("Folder")
	audio.Name = "Audio"
	audio.Parent = modules.Parent
	local Config = require(modules.Config)
	local soundSettings = Config.getSetting(SOUND_KEY)
	local soundGroups = createGroup("Groups", audio)
	for soundAction, details in soundSettings do
		for soundType, _ in details do
			createGroup(soundType, soundGroups)
		end
	end
end

-- If is client, listen for changes in settings and apply to the soundGroups locally
if isClient then
	task.spawn(function()
		local clientUser = require(modules.References.clientUser)
		local userPerm = clientUser.perm
		local audio = modules.Parent:WaitForChild("Audio", 999999)
		local soundGroups = audio:WaitForChild("Groups", 999999)
		local function bindSound(soundInstance)
			if not soundInstance:IsA("Sound") then
				return
			end
			local soundType = soundInstance:GetAttribute("HDAdminSoundType")
			if not soundType then
				return
			end
			local typeGroup = soundGroups:FindFirstChild(soundType)
			if not typeGroup then
				return
			end
			soundInstance.SoundGroup = typeGroup
		end
		CollectionService:GetInstanceAddedSignal(TAG):Connect(bindSound)
		for _, soundInstance in pairs(CollectionService:GetTagged(TAG)) do
			bindSound(soundInstance)
		end
		userPerm:fetch(SETTINGS_KEY, SOUND_KEY, function(soundSettings)
			for soundAction, details in soundSettings do
				local handler = HANDLERS[soundAction]
				if not handler then
					continue
				end
				for soundType, _ in details do
					local typeGroup = soundGroups[soundType]
					userPerm:observe(SETTINGS_KEY, SOUND_KEY, soundAction, soundType, function(value)
						handler(typeGroup, value)
					end)
				end
			end
		end)
	end)
end

-- Just tag sound and CollectionService handles replication
return function(sound: Sound, soundType: SoundType?)
	if not soundType then
		soundType = if isClient then "Interface" else "Command"
	end
	if not(typeof(sound) == "Instance" and sound:IsA("Sound")) then
		return error("Invalid sound provided")
	end
	sound:SetAttribute("HDAdminSoundType", soundType)
	CollectionService:AddTag(sound, TAG)
	return sound
end