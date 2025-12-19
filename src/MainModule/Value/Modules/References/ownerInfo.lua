--!strict

-- This module yield's the first time called
local creatorId = game.CreatorId
local ownerInfo = {
	ownerId = creatorId,
	ownerName = "Unknown",
}

-- If game is published by an individual, simply load creator's name
if game.CreatorType ~= Enum.CreatorType.Group then
	local Players = game:GetService("Players")
	local success, userName = pcall(function()
		return Players:GetNameFromUserIdAsync(creatorId)
	end)
	if success and userName then
		ownerInfo.ownerName = userName
	end
	return ownerInfo
end

-- If game is published by a group, we need to fetch the group's owner info
local success, groupInfo
local GroupService = game:GetService("GroupService")
repeat
	-- We repeat indefinitely to avoid even extremely rare scenarios of
	-- a userId's matching a groupId's, and ultimately giving that user
	-- the 'creator' role unintentionally
	success, groupInfo = pcall(function()
		return GroupService:GetGroupInfoAsync(game.CreatorId).Owner
	end)
	if success then
		break
	end
	task.wait(1)
until success
if success then
	ownerInfo.ownerId = groupInfo.Id
	ownerInfo.ownerName = groupInfo.Name
end
return ownerInfo