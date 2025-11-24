local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local States = require(UI.States)
local Fusion = require(Packages.Fusion)
local Callbacks = require(UI.Callbacks)

local CosmeticsStateMod = {}

function CosmeticsStateMod:SetEquipped(Id: string, Equipped: boolean)
	local CosmeticsValue = Fusion.peek(States.Perks.Cosmetics.Worn)

	local CosmeticIndex = table.find(CosmeticsValue, Id)

	if (Equipped == true) and (CosmeticIndex == nil) then
		table.insert(CosmeticsValue, Id)
	elseif (Equipped == false) and (CosmeticIndex ~= nil) then
		table.remove(CosmeticsValue, CosmeticIndex)
	end

	States.Perks.Cosmetics.Worn:set(CosmeticsValue)

	Callbacks.ToggleCosmetic(Id, Equipped)
end

function CosmeticsStateMod:Toggle(Id: string)
	local Equipped = CosmeticsStateMod:IsEquipped(Id)

	CosmeticsStateMod:SetEquipped(Id, not Equipped)

	Callbacks.ToggleCosmetic(Id, not Equipped)
end

function CosmeticsStateMod:IsEquipped(Id: string): boolean
	local CosmeticsValue = Fusion.peek(States.Perks.Cosmetics.Worn)

	return table.find(CosmeticsValue, Id) ~= nil
end

return CosmeticsStateMod
