-- These are the items which the user can buy
-- We retrieve accessories separately using Desc:GetAccessories()
local SInstance = {}
SInstance.DataLimit = 250
SInstance.GetChildren = false
SInstance.Template = {
	["Face"] = 0,
	["Head"] = 0,
	["LeftArm"] = 0,
	["LeftLeg"] = 0,
	["RightArm"] = 0,
	["RightLeg"] = 0,
	["Torso"] = 0,
	["GraphicTShirt"] = 0,
	["Pants"] = 0,
	["Shirt"] = 0,
}
return SInstance