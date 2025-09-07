local HDAdminUI = script.Parent.Parent
local States = require(HDAdminUI.States)
local Fusion = require(HDAdminUI.Parent.Parent.Parent.Packages.Fusion)
local Signals = require(HDAdminUI.Signals)

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

	Signals.CosmeticToggled:Fire(Id, Equipped)
end

function CosmeticsStateMod:Toggle(Id: string)
	local Equipped = CosmeticsStateMod:IsEquipped(Id)

	CosmeticsStateMod:SetEquipped(Id, not Equipped)

	Signals.CosmeticToggled:Fire(Id, not Equipped)
end

function CosmeticsStateMod:IsEquipped(Id: string): boolean
	local CosmeticsValue = Fusion.peek(States.Perks.Cosmetics.Worn)

	return table.find(CosmeticsValue, Id) ~= nil
end

return CosmeticsStateMod
