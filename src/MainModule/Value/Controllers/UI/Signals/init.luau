local HDAdminUI = script.Parent
local Signal = require(HDAdminUI.Parent.Parent.Packages.Signal)

local COMMAND_RAN: Signal.Signal<string, { any }> = Signal.new()
local USER_BANNED: Signal.Signal<number> = Signal.new()
local USER_UNBANNED: Signal.Signal<number> = Signal.new()
local USER_KICKED: Signal.Signal<number> = Signal.new()
local USER_WARNED: Signal.Signal<number> = Signal.new()
local USER_ROLE_REVOKED: Signal.Signal<number, string> = Signal.new()
local COSMETIC_TOGGLED: Signal.Signal<string, boolean> = Signal.new()
local COSMETICS_CHECKED_OUT: Signal.Signal<{ string }> = Signal.new()
local COMMAND_STOPPED: Signal.Signal<string> = Signal.new()
local BOOSTER_PURCHASE_INITIATED: Signal.Signal<> = Signal.new()
local USER_PROFILE_REQUESTED: Signal.Signal<number> = Signal.new()

local Signals = {
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
	UserProfileRequested = USER_PROFILE_REQUESTED,
}

return Signals
