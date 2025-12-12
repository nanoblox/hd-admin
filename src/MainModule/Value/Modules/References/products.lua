-- Changing any products here violates HD Admin's Terms of Service
-- and revokes your permission to legally use HD Admin
local function register(item: Product): Product
	return item :: Product
end

local products = {
	----------------
	["LaserEyes"] = register({
		Id = 1007746205,
		Type = "GamePass",
	}),

	----------------
	["OldBooster"] = register({
		Id = 1007884962,
		Type = "GamePass",
	}),

	----------------
	["OldDonor"] = register({
		Id = 5745895,
		Type = "GamePass",
	}),

	----------------
	["Booster"] = register({
		Id = 91265843061691,
		Type = "UGC",
	}),

	----------------
	["BoosterDiscount"] = register({
		Id = 78104307094868,
		Type = "UGC",
	}),

	----------------
}

export type ProductType = "GamePass" | "DevProduct" | "Accessory" | "Bundle" | "Emote"
export type ProductName = keyof<typeof(products)>
export type Product = {
	Id: number,
	Type: ProductType,
}

return products :: {[ProductName]: Product}