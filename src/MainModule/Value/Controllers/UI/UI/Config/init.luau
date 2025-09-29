local HDAdminUI = script.Parent
local Stator = require(HDAdminUI.Parent.Parent.Parent.Packages.Stator)

local DEFAULT_CONFIG = {
	Icons = require(script.Icons),
	Commands = require(script.Commands),
	Credits = require(script.Credits),
	Cosmetics = require(script.Cosmetics),
	FeaturedCosmetics = require(script.FeaturedCosmetics),
	DonationProducts = require(script.DonationProducts),
	Donators = require(script.Donators),
	Roles = require(script.Ranks),
	Version = require(script.Version),
}

local Config = Stator(DEFAULT_CONFIG, {})

return Config
