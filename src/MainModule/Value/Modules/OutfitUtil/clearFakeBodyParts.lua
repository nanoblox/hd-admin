return function (character)
	if not character then return end
	for a,b in pairs(character:GetDescendants()) do
		if b:IsA("BasePart") then
			if string.sub(b.Name, 1, 4) == "Fake" then
				b:SetAttribute("DisableMorphPart", true)
				b:Destroy()
			elseif b.Name ~= "HumanoidRootPart" then
				b.Transparency = 0
			end
		end
	end
end