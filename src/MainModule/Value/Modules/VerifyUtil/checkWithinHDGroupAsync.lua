local modules = script:FindFirstAncestor("MainModule").Value.Modules
local Remote = require(modules.Objects.Remote)
local joinHDGroup = Remote.new("JoinHDGroup")
local recentResult: {[string]: boolean} = {}
local loadingResult: {[string]: boolean} = {}

joinHDGroup:onServerEvent(function(player: Player)
	-- Minimal validation, as only a temporary value to overcome
	-- Roblox's 60 second InGroup cache. No important
	-- verification is handled via this
	if not player:GetAttribute("JoinedHDGroup") then
		player:SetAttribute("JoinedHDGroup", true)
	end
end)

return function (player: Player): boolean
	local playerName = player.Name
	if loadingResult[playerName] then
		repeat task.wait(0.05) until not loadingResult[playerName]
	end
	local lastResult = recentResult[playerName]
	if lastResult then
		return lastResult
	end
	local GROUP_ID = 4676369
	loadingResult[playerName] = true
	local alreadyJoined = player:GetAttribute("JoinedHDGroup")
	local success, isInGroup
	if not alreadyJoined then
		success, isInGroup = pcall(function()
			return player:IsInGroupAsync(GROUP_ID)
		end)
	end
	local returnValue: boolean = false
	if alreadyJoined or (success and isInGroup == true) then
		returnValue = true
	else
		joinHDGroup:fireClient(player, GROUP_ID, `Group exclusive command - join HD Admin to unlock!`)
	end
	recentResult[playerName] = returnValue
	loadingResult[playerName] = nil
	task.delay(0.5, function()
		recentResult[playerName] = nil
	end)
	return returnValue
end