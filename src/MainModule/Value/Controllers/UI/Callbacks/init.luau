local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local Packages = Main.Value.Packages
local Types = require(UI.Utils.Types)

local COMMAND_RAN: (Name: string, Arguments: { any }) -> boolean = function() end
local USER_BANNED: (UserId: number) -> boolean = function() end
local USER_UNBANNED: (UserId: number) -> boolean = function() end
local USER_KICKED: (UserId: number) -> boolean = function() end
local USER_WARNED: (UserId: number) -> boolean = function() end
local USER_ROLE_REVOKED: (UserId: number, Role: string) -> boolean = function() end
local COSMETIC_TOGGLED: (Cosmetic: string, Worn: boolean) -> boolean = function() end
local COSMETICS_CHECKED_OUT: (Cosmetics: { string }) -> boolean = function() end
local COMMAND_STOPPED: (Command: string) -> boolean = function() end
local BOOSTER_PURCHASE_INITIATED: () -> boolean = function() end
local USER_INFO_REQUESTED: (UserId: number) -> (boolean, Types.User) = function()
	return {}
end
local COMMAND_INFO_REQUESTED: (UserId: number) -> (boolean, Types.Command) = function()
	return {}
end

local Callbacks = {
	CommandRan = COMMAND_RAN,
	CommandStopped = COMMAND_STOPPED,
	UserBanned = USER_BANNED,
	UserUnbanned = USER_UNBANNED,
	UserKicked = USER_KICKED,
	UserWarned = USER_WARNED,
	UserRoleRevoked = USER_ROLE_REVOKED,
	CosmeticToggled = COSMETIC_TOGGLED,
	CosmeticsCheckedOut = COSMETICS_CHECKED_OUT,
	BoosterPurchaseInitiated = BOOSTER_PURCHASE_INITIATED,
	UserInfoRequested = USER_INFO_REQUESTED,
	CommandInfoRequested = COMMAND_INFO_REQUESTED,
}

return Callbacks
