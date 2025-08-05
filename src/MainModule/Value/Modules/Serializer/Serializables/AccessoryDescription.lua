local SInstance = {}
SInstance.DataLimit = 250
SInstance.GetChildren = false
SInstance.Template = {
	["AccessoryType"] = Enum.AccessoryType.Unknown,
	["AssetId"] = 0,
	["IsLayered"] = false,
	["Order"] = 0,
	["Position"] = Vector3.new(0,0,0),
	["Puffiness"] = 0,
	["Rotation"] = Vector3.new(0,0,0),
	["Scale"] = Vector3.new(1, 1, 1),
}
--print(#game.HttpService:JSONEncode(SInstance.Template))
return SInstance