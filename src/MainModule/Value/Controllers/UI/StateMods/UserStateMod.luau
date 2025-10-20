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

local UserStateMod = {}

function UserStateMod.GetSafe(
	Scope: Fusion.Scope<typeof(Fusion)>,
	User: typeof(UserStateMod.Get(Fusion.scoped(), 1))
): Fusion.Computed<Types.User>
	return Scope:Computed(function(Use)
		local UserValue = Use(User)

		return Sift.Dictionary.merge({
			UserId = 1,
			Username = "Username",
			DisplayName = "User",
			AccountAge = -1,
			Roles = { "Guest" },
			Warnings = {},
			Bans = {},
		}, UserValue or {})
	end)
end

function UserStateMod.Get(
	Scope: Fusion.Scope<typeof(Fusion)>,
	UserId: Fusion.UsedAs<number>
): Fusion.Computed<Types.User?>
	local function GetDetails(UserId: number)
		local UsersValue = Fusion.peek(States.Users.Profiles)
		local ExistingDetails = UsersValue[UserId]

		if ExistingDetails == nil then
			Future.Try(function()
				UserStateMod.Load(UserId)
			end)
		end
	end

	GetDetails(Fusion.peek(UserId))
	Scope:Observer(UserId):onChange(function()
		GetDetails(Fusion.peek(UserId))
	end)

	return Scope:Computed(function(Use)
		return Use(States.Users.Profiles)[Use(UserId)]
	end)
end

function UserStateMod.Load(UserId: number): boolean
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
