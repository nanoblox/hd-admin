local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local Packages = Main.Value.Packages
local Types = require(UI.Utils.Types)

local RUN_COMMAND: (Name: string, Arguments: { any }) -> boolean = function() end
local BAN_USER: (UserId: number) -> boolean = function() end
local UNBAN_USER: (UserId: number) -> boolean = function() end
local KICK_USER: (UserId: number) -> boolean = function() end
local WARN_USER: (UserId: number) -> boolean = function() end
local REVOKE_USER_ROLE: (UserId: number, Role: string) -> boolean = function() end
local TOGGLE_COSMETIC: (Cosmetic: string, Worn: boolean) -> boolean = function() end
local PURCHASE_COSMETICS: (Cosmetics: { string }) -> boolean = function() end
local STOP_COMMAND_TASKS: (Command: string) -> boolean = function() end
local PURCHASE_BOOSTER: () -> boolean = function() end
local REQUEST_USER_INFO: (UserId: number) -> (boolean, Types.User) = function()
	return {}
end
local REQUEST_COMMAND_INFO: (Name: string) -> (boolean, Types.Command) = function()
	return {}
end

local Callbacks = {
	RunCommand = RUN_COMMAND,
	StopCommandTasks = STOP_COMMAND_TASKS,
	BanUser = BAN_USER,
	UnbanUser = UNBAN_USER,
	KickUser = KICK_USER,
	WarnUser = WARN_USER,
	RevokeUserRole = REVOKE_USER_ROLE,
	ToggleCosmetic = TOGGLE_COSMETIC,
	PurchaseCosmetics = PURCHASE_COSMETICS,
	PurchaseBooster = PURCHASE_BOOSTER,
	RequestUserInfo = REQUEST_USER_INFO,
	RequestCommandInfo = REQUEST_COMMAND_INFO,
}

return Callbacks
