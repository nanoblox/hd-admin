--!strict
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local ownerInfo = require(modules.References.ownerInfo)

return {

	["Owner"] = {
		ownerInfo.ownerId, -- The creator or group owner of the game
	},

	["Devs"] = {
		82347291, -- ForeverHD
		"Builderman", -- 156
	},

	["Influencers"] = {
		46138509, -- ObliviousHD
		"mrflimflam", -- 339310190
	},

}