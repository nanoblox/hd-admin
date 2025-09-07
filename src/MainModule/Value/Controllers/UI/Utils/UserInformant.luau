local Players = game:GetService("Players")
local UserService = game:GetService("UserService")

local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local Future = require(HDAdminUI.Parent.Parent.Packages.Future)
local Sift = require(HDAdminUI.Parent.Parent.Packages.Sift)

local Scope = Fusion.scoped(Fusion)

export type UserInfo = {
	UserId: number,
	Username: string?,
	DisplayName: string?,
	AccountAge: number?,
}

local UserInformant = {
	UserInfos = {},
}

function UserInformant.Users(UserIds: { number })
	return Sift.Array.map(UserIds, function(UserId: number)
		return UserInformant.User(UserId)
	end)
end

function UserInformant.User(UserId: number): UserInfo
	local ExistingDetails = UserInformant.UserInfos[UserId]
	if ExistingDetails then
		return ExistingDetails
	end

	local Details = {
		UserId = UserId,
		Player = Players:GetPlayerByUserId(UserId),
		Username = UserInformant.Username(UserId),
		DisplayName = UserInformant.DisplayName(UserId),
		AccountAge = UserInformant.AccountAge(UserId),
	}

	UserInformant.UserInfos[UserId] = Details

	return Details
end

function UserInformant.Username(UserId): string?
	local Player = Players:GetPlayerByUserId(UserId)

	if Player then
		return Player.Name
	else
		local Success, Result = Future.Try(function()
			return Players:GetNameFromUserIdAsync(UserId)
		end):Await()
		if Success then
			return Result
		end
	end

	return nil
end

function UserInformant.DisplayName(UserId): string?
	local Player = Players:GetPlayerByUserId(UserId)

	if Player then
		return Player.DisplayName
	else
		local Success, Result = Future.Try(function()
			return UserService:GetUserInfosByUserIdsAsync({ UserId })[1].DisplayName
		end):Await()
		if Success then
			return Result
		end
	end

	return nil
end

function UserInformant.AccountAge(UserId): number?
	local Player = Players:GetPlayerByUserId(UserId)

	if Player then
		return Player.AccountAge
	end

	return nil
end

function UserInformant.UserIdFromUsername(Username: string): number?
	local Success, Result = Future.Try(function()
		return Players:GetUserIdFromNameAsync(Username)
	end):Await()

	if Success then
		return Result
	end

	return nil
end

return UserInformant
