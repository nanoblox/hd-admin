local Main = script:FindFirstAncestor("MainModule")
local UI = Main.Value.Controllers.UI
local Types = require(UI.Utils.Types)

local ROLES: {
	[string]: Types.Role,
} = {
	Guest = {
		Name = "Guest",
		Color = Color3.fromHex("FFFFFF"),
		Level = 0,
	},
	VIP = {
		Name = "VIP",
		Color = Color3.fromHex("FFFFFF"),
		Level = 1,
	},
	Mod = {
		Name = "Mod",
		Color = Color3.fromHex("FFFFFF"),
		Level = 2,
	},
	Admin = {
		Name = "Admin",
		Color = Color3.fromHex("FFFFFF"),
		Level = 3,
	},
	Owner = {
		Name = "Owner",
		Color = Color3.fromHex("FFFFFF"),
		Level = 4,
	},
}

return ROLES
