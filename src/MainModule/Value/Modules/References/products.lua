-- Changing any products here violates HD Admin's Terms of Service
-- and revokes your permission to legally use HD Admin
local function register(item: Product): Product
	return item :: Product
end

local products = {
	----------------
	["LaserEyes"] = register({
		passId = 1007746205,
		passType = Enum.InfoType.GamePass,
	}),

	----------------
	["OldBooster"] = register({
		passId = 1007884962,
		passType = Enum.InfoType.GamePass,
	}),

	----------------
	["OldDonor"] = register({
		passId = 5745895,
		passType = Enum.InfoType.GamePass,
	}),

	----------------
	["Booster"] = register({
		passId = 91265843061691,
		passType = Enum.InfoType.Asset,
	}),

	----------------
	["BoosterDiscount"] = register({
		passId = 78104307094868,
		passType = Enum.InfoType.Asset,
	}),

	----------------
}

export type ProductName = keyof<typeof(products)>
export type Product = {
	passId: number,
	passType: Enum.InfoType,
}

return products :: {[ProductName]: Product}