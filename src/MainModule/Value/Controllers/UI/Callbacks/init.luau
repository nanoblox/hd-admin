local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local Packages = Main.Value.Packages
local Types = require(UI.Utils.Types)
local Config = require(UI.Config)
local UserInformant = require(UI.Utils.UserInformant)
local Sift = require(Packages.Sift)

local CONFIG = Config:Get()

local RUN_COMMAND: (Name: string, Arguments: { any }) -> boolean = function() end
local TOGGLE_COSMETIC: (Cosmetic: string, Worn: boolean) -> boolean = function() end
local PURCHASE_COSMETICS: (Cosmetics: { string }) -> boolean = function() end
local STOP_COMMAND_TASKS: (Command: string) -> boolean = function() end
local PURCHASE_BOOSTER: () -> boolean = function() end
local REQUEST_USER_INFO: (UserId: number) -> (boolean, Types.User) = function(UserId)
	if RunService:IsEdit() then
		local BaseInfo = UserInformant.User(UserId)

		if UserId == 1 then
			return true,
				Sift.Dictionary.merge({
					Roles = { "Owner" },
					Warnings = {
						{
							Timestamp = os.time(),
							Reason = "Warning reason here.",
						},
					},
					Bans = {
						{
							Timestamp = os.time(),
							Duration = 10 ^ 1000,
							Reason = "Ban reason here.",
						},
					},
				}, BaseInfo)
		else
			return true, BaseInfo
		end
	end
end
local PURCHASE_ROLE_GAMEPASS: (GamepassId: number) -> boolean = function(GamepassId)
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, GamepassId)
end

local Callbacks = {
	RunCommand = RUN_COMMAND,
	StopCommandTasks = STOP_COMMAND_TASKS,
	ToggleCosmetic = TOGGLE_COSMETIC,
	PurchaseCosmetics = PURCHASE_COSMETICS,
	PurchaseBooster = PURCHASE_BOOSTER,
	RequestUserInfo = REQUEST_USER_INFO,
	PurchaseRoleGamepass = PURCHASE_ROLE_GAMEPASS,
}

return Callbacks
