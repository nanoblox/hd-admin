local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local UserInformant = require(UI.Utils.UserInformant)
local States = require(UI.States)
local Callbacks = require(UI.Callbacks)
local Types = require(UI.Utils.Types)
local Future = require(Packages.Future)
local Sift = require(Packages.Sift)

local Scope = Fusion.scoped(Fusion)

local UserStateMod = {}

function UserStateMod:GetSafe(UserId: number): Fusion.Computed<Types.User>
	return Scope:Computed(function(Use)
		local UserValue = Use(UserStateMod:Get(UserId))

		return Sift.Dictionary.merge(UserValue or {}, {
			UserId = UserId,
			Username = "Username",
			DisplayName = "User",
			AccountAge = -1,
			Roles = {},
			Warnings = {},
			Bans = {},
		})
	end)
end

function UserStateMod:Get(UserId: number): Fusion.Computed<Types.User?>
	local UsersValue = Fusion.peek(States.Users.Profiles)
	local ExistingDetails = UsersValue[UserId]

	if ExistingDetails == nil then
		Future.Try(function()
			UserStateMod:Load(UserId)
		end)
	end

	return Scope:Computed(function(Use)
		return Use(States.Users.Profiles)[UserId]
	end)
end

function UserStateMod:Load(UserId: number): boolean
	local Success, UserInfo = Callbacks.RequestUserInfo(UserId)

	if Success then
		local UsersValue = Fusion.peek(States.Users.Profiles)

		UsersValue[UserId] = UserInfo

		States.Users.Profiles:set(UsersValue)

		return true
	end

	return false
end

return UserStateMod
