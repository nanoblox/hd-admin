local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local UserInformant = require(UI.Utils.UserInformant)
local States = require(UI.States)
local Signals = require(UI.Signals)

local Scope = Fusion.scoped(Fusion)

export type Profile = {
	UserId: number,
	Username: string,
	DisplayName: string,
	AccountAge: number?,
}

local UserStateMod = {}

function UserStateMod:Get(UserId: number): Profile
	local UserProfilesValue = Fusion.peek(States.Users.Profiles)
	local ExistingDetails = UserProfilesValue[UserId]

	if ExistingDetails == nil then
		task.spawn(function()
			UserStateMod:Load(UserId)
		end)
	end

	return Scope:Computed(function(Use)
		return Use(States.Users.Profiles)[UserId]
	end)
end

function UserStateMod:Load(UserId: number)
	Signals.UserProfileRequested:Fire(UserId)
end

return UserStateMod
