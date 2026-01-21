--!strict
-- LOCAL
local ClientAssets = {}
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)


-- SETUP
-- Initialize the Sound Handler
require(modules.AssetUtil.registerSound)

-- Plays sound on client
Remote.get("PlaySoundInstance"):onClientEvent(function(soundInstance)
	if soundInstance then
		soundInstance:Play()
	end
end)

-- Bind audio within server 'playTextToSpeech'
Remote.get("BindAudioEmitter"):onClientEvent(function(audioEmitter, audioSource)
	if not audioEmitter then
		return
	end
	local listener = Instance.new("AudioListener")
	listener.Name = "HDAudioListener"
	listener.Parent = workspace.CurrentCamera
	local audioOutput = Instance.new("AudioDeviceOutput")
	audioOutput.Parent = listener
	local wire = Instance.new("Wire")
	wire.Parent = audioOutput
	wire.SourceInstance = listener
	wire.TargetInstance = audioOutput
	local wire = Instance.new("Wire")
	wire.Parent = listener
	wire.SourceInstance = listener
	wire.TargetInstance = audioEmitter
	local hasCleaned = false
	local function cleanup()
		if hasCleaned then
			return
		end
		hasCleaned = true
		listener:Destroy()
	end
	audioEmitter.Destroying:Once(cleanup)
	audioSource:Play()
	audioSource.Ended:Once(cleanup)
end)


return ClientAssets