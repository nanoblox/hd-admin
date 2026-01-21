--!strict
-- LOCAL
local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Prompt = require(modules.Prompt)
local Task = require(modules.Objects.Task)
local EncodingService = game:GetService("EncodingService")
local Players = game:GetService("Players")
local getAnimator = require(modules.PlayerUtil.getAnimator)
local getHRP = require(modules.PlayerUtil.getHRP)
local bundleIdToAnimId: {[string]: number} = {}


-- LOCAL FUNCTIONS
local function setTorsoSoundSpeed(player: Player, speed: number)
	local hrp = getHRP(player)
	local torsoSound = hrp and hrp:FindFirstChild("HDTorsoSound")
	if torsoSound and torsoSound:IsA("Sound") then
		local difference = speed - 1
		local newSpeed = 1 + (difference/2)
		torsoSound.PlaybackSpeed = newSpeed or 1
	end
end

local function playAnimation(player: Player, animationId: number, customSpeed: number?, looped: boolean?): (AnimationTrack?, Animation?)
	local speed = customSpeed or 1
	local loadTrack = require(modules.PlayerUtil.loadTrack)
	local animTrack, animation = loadTrack(player, animationId)
	if not animTrack or not animation then
		return nil, nil
	end
	local weight = (looped and 98) or 99
	local isLooped = looped == true
	animTrack.Looped = isLooped
	animTrack.Priority = Enum.AnimationPriority.Core
	animTrack:Play(1, weight, speed)
	setTorsoSoundSpeed(player, speed)
	animation:SetAttribute("HDSpeed", speed)
	animation:GetAttributeChangedSignal("HDSpeed"):Connect(function()
		local newSpeed = animation:GetAttribute("HDSpeed")
		if typeof(newSpeed) == "number" then
			animTrack:AdjustSpeed(newSpeed)
		end
	end)
	local animator = getAnimator(player)
	if not isLooped and animator then
		local length
		for i = 1, 200 do
			length = animTrack.Length
			if length and length > 0 then
				length = length - animTrack.TimePosition
				break
			end
			task.wait(0.02)
		end
		local fadeTime = 1
		if not length then
			length = 0
			fadeTime = 0
		end
		local trackCount: any = animation:GetAttribute("TrackCount")
		if typeof(trackCount) ~= "number" then
			trackCount = 0
		end
		trackCount += 1
		animation:SetAttribute("TrackCount", trackCount)
		length = length :: number
		local delayTime: number = length - fadeTime
		task.delay(delayTime, function()
			if animation.Parent then
				animTrack:AdjustWeight(-1)
				animTrack.Priority = Enum.AnimationPriority.Core
				animTrack:Stop(fadeTime)
			end
			task.delay(fadeTime, function()
				local trackCount: any = animation:GetAttribute("TrackCount") or 1
				trackCount -= 1
				animation:SetAttribute("TrackCount", trackCount)
				if trackCount <= 0 then
					animation:Destroy()
				end
			end)
		end)
	end
	local character = player.Character
	if character then
		animation.Parent = character
	end
	return animTrack, animation
end

local function getAnimIdFromEmoteIdAsync(emoteId: number): (boolean, number | string)
	local Emotes = require(modules.Parent.Services.Emotes)
	local emote = Emotes.getEmoteById(emoteId)
	local emoteAnimId = emote and emote.animationId
	if emoteAnimId then
		return true, emoteAnimId
	end
	local stringId = tostring(emoteId)
	local animId = bundleIdToAnimId[stringId]
	if animId then
		return true, animId
	end
	local success, model = pcall(function()
		local AssetService = game:GetService("AssetService")
		return AssetService:LoadAssetAsync(emoteId)
	end)
	if not success then
		return false, tostring(model)
	end
	local animation = success and model:FindFirstChildOfClass("Animation")
	if not animation then
		model:Destroy()
		return false, "No animation in asset"
	end
	local animationId = tonumber(animation.AnimationId:match("%d+"))
	if not animationId then
		model:Destroy()
		return false, "Invalid animation ID"
	end
	bundleIdToAnimId[stringId] = animationId
	animation:Destroy()
	return true, animationId
end

local function runEmoteId(task: Task.Class, emoteId: number, speed: number?, looped: boolean?)
	--[[
	if not isFromClient then
		if isCustomRank then
			main:GetModule("cf"):CheckFirstTimeUsing(plr, "HDFirstTimeUsingCustom", function()
				--main.signals.CreateEmotesMenu:FireClient(plr)
			end)
		else
			main:GetModule("cf"):CheckFirstTimeUsing(plr)
		end
	end--]]
	local success, animId = getAnimIdFromEmoteIdAsync(emoteId)
	if not success then
		Prompt.error(task.caller, `Failed to run emote ID {emoteId}: {animId}`)
		return
	end
	task:keep("UntilTargetRespawns")
	local target = task.target :: Player
	local animTrack, animation = playAnimation(target, animId :: number, speed, looped)
	local janitor = task.janitor
	if animTrack then
		janitor:add(function()
			animTrack:Stop()
			animTrack:Destroy()
		end)
	end
	if animation then
		janitor:add(animation)
	end
end


return runEmoteId