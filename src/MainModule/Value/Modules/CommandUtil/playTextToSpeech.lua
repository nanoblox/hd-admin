--!strict
local cachedTextToAudioSources = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local getHRP = require(modules.PlayerUtil.getHRP)
local sharedAssets = require(modules.References.sharedAssets)
local Remote = require(modules.Objects.Remote)
local bindAudioEmitter = Remote.new("BindAudioEmitter", "Event")

return function(player: Player, text: string, voice: string?)
	
	if typeof(text) ~= "string" then
		return
	end
	
	local hrp = getHRP(player)
	if not hrp then
		return
	end
	
	-- Either use already created item, or create new one
	-- It's important to cache these, to limit request budgets
	-- within the game server
	local audioTextToSpeech = cachedTextToAudioSources[text]
	if not audioTextToSpeech then
		audioTextToSpeech = Instance.new("AudioTextToSpeech")
		cachedTextToAudioSources[text] = audioTextToSpeech
		audioTextToSpeech.Name = text
		audioTextToSpeech.Text = text
		audioTextToSpeech.VoiceId = voice or "9"
		audioTextToSpeech.Speed = 1.25
		audioTextToSpeech.PlaybackSpeed = 1.25
		audioTextToSpeech.Parent = sharedAssets
	end
	
	-- AudioEmitters seem to randomly produce distorted sounds,
	-- which even after investing, such as (https://devforum.roblox.com/t/-/3739522/2),
	-- I can't seem to find a solid fix, so I've temporary replaced
	-- with DeviceOutput which doesn't have spatial sound, but at
	-- least doesn't distort the audio in unpleasant ways
	local voiceParent = hrp
	local audioEmitter = Instance.new("AudioDeviceOutput")
	audioEmitter.Name = text
	audioEmitter.Parent = voiceParent
	--[[
	audioEmitter:SetDistanceAttenuation({
		[0] = 0.5,
		[5] = 0.5,
		[35] = 0,
	})--]]
	
	-- Wire TTS to AudioEmitter (spatialized sound)
	local wire = Instance.new("Wire")
	wire.Name = "HDWire"
	wire.SourceInstance = audioTextToSpeech
	wire.TargetInstance = audioEmitter
	wire.Parent = audioEmitter

	-- Play on clients
	-- Disabled for FireAllClients for now, will potentially add back later
	-- after getting community feedback
	--main.signals.BindAudioEmitter:FireAllClients({audioEmitter, audioTextToSpeech})
	bindAudioEmitter:fireClient(player, audioEmitter, audioTextToSpeech)
	task.delay(5, function()
		audioEmitter:Destroy()
	end)
end