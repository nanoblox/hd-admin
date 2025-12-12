return function(instance: Instance, transparency: number)
	for _, child in pairs(instance:GetDescendants()) do
		if (child:IsA("BasePart") and child.Name ~= "HumanoidRootPart") or (child.Name == "face" and child:IsA("Decal")) then
			child.Transparency = transparency
		elseif (child:IsA("ParticleEmitter") and child.Name == "BodyEffect") or child:IsA("PointLight") or child:IsA("BillboardGui") then
			child.Enabled = child.Enabled and transparency < 1
		end
	end
end