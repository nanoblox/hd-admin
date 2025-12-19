--!strict
--[[ To do: in the future:
		1. Add PrimaryRole
		2. I can defer by 0.01 seconds, collect multiple requests
		   all at once, and handle them in batch with GetUserInfosByUserIdsAsync
]]


local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local cachedInfo = {}

export type UserInfo = {
	userId: number | string,
	userName: string,
	userImage: string,
	userDisplayName: string,
	userPrimaryRole: string,
}

local function getUserInfoAsync(userId: number | string): (boolean, UserInfo | string)
	if typeof(userId) ~= "number" then
		return true, {
			userId = userId,
			userName = "System",
			userImage = "",
			userDisplayName = "System",
			userPrimaryRole = "", -- UPDATE THIS IN FUTURE WITH PRIMARY ROLE!!!
		}
	end
	local image = `https://www.roblox.com/headshot-thumbnail/image?userId={userId}&width=420&height=420&format=png`
	local playerInServer = Players:GetPlayerByUserId(userId)
	if playerInServer then
		return true, {
			userId = userId,
			userName = playerInServer.Name,
			userImage = image,
			userDisplayName = playerInServer.DisplayName,
			userPrimaryRole = "Unknown", -- UPDATE THIS IN FUTURE WITH PRIMARY ROLE!!!
		}
	end
	local success, userDetails = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({userId})
	end)
	if not success or not userDetails or #userDetails <= 0 then
		return false, tostring(userDetails)
	end
	local firstRecord = userDetails[1]
	if typeof(firstRecord) ~= "table" then
		return false, "Failed to find info"
	end
	return true, {
		userId = firstRecord.Id,
		userName = firstRecord.Username,
		userImage = image,
		userDisplayName = firstRecord.DisplayName,
		userPrimaryRole = "Unknown", -- UPDATE THIS IN FUTURE WITH PRIMARY ROLE!!!
	}
end

return function(userId: number | string): (boolean, UserInfo | string)
	local userInfo = cachedInfo[userId]
	if userInfo then
		return true, userInfo
	end
	local success, infoOrError = getUserInfoAsync(userId)
	if success then
		cachedInfo[userId] = infoOrError :: any
		task.delay(300, function()
			cachedInfo[userId] = nil
		end)
		return true, infoOrError
	end
	return false, infoOrError
end