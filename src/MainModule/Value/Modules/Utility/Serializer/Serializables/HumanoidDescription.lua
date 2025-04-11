local SInstance = {}
SInstance.DataLimit = 5000 -- 5000 Bytes to account for AccessoryBlob becoming more prominant in future
SInstance.GetChildren = true
SInstance.ChildrenAllowlist = {"AccessoryDescription", "BodyPartDescription"}
SInstance.ProcessInstance = function(originalInstance)
	local AvatarEditorService = game:GetService("AvatarEditorService")
	local success, newInstance = pcall(function()
		return AvatarEditorService:ConformToAvatarRules(originalInstance)
	end)
	if not success then
		newInstance = Instance.new("HumanoidDescription")
	end
	newInstance.Name = originalInstance.Name
	return newInstance
end
SInstance.Template = {
	
	-- Accessories
	["BackAccessory"] = "0",
	["FaceAccessory"] = "0",
	["FrontAccessory"] = "0",
	["HairAccessory"] = "0",
	["HatAccessory"] = "0",
	["NeckAccessory"] = "0",
	["ShouldersAccessory"] = "0",
	["WaistAccessory"] = "0",
	
	-- Animation
	["ClimbAnimation"] = 0,
	["FallAnimation"] = 0,
	["IdleAnimation"] = 0,
	["JumpAnimation"] = 0,
	["MoodAnimation"] = 0,
	["RunAnimation"] = 0,
	["SwimAnimation"] = 0,
	["WalkAnimation"] = 0,
	
	-- Body Colors
	["HeadColor"] = Color3.new(1,1,1),
	["LeftArmColor"] = Color3.new(1,1,1),
	["LeftLegColor"] = Color3.new(1,1,1),
	["RightArmColor"] = Color3.new(1,1,1),
	["RightLegColor"] = Color3.new(1,1,1),
	["TorsoColor"] = Color3.new(1,1,1),
	
	-- Body Parts
	["Face"] = 0,
	["Head"] = 0,
	["LeftArm"] = 0,
	["LeftLeg"] = 0,
	["RightArm"] = 0,
	["RightLeg"] = 0,
	["Torso"] = 0,
	
	-- Clothes
	["GraphicTShirt"] = 0,
	["Pants"] = 0,
	["Shirt"] = 0,
	
	-- Scale
	["BodyTypeScale"] = 0,
	["DepthScale"] = 0,
	["HeadScale"] = 0,
	["HeightScale"] = 0,
	["ProportionScale"] = 0,
	["WidthScale"] = 0,
}
--print(#game.HttpService:JSONEncode(SInstance.Template))


return SInstance