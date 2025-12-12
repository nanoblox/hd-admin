return function(instance: Instance, anchored: boolean)
	local function anchor(part)
		if part:IsA("BasePart") then
			part.Anchored = anchored
		end
	end
	anchor(instance)
	for _, part in pairs(instance:GetDescendants()) do
		anchor(part)
	end
end