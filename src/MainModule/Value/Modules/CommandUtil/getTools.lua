--!strict
-- Check all items within ReplicatedStorage, ServerStorage, Lighting, and StarterPack
local toolsArray: {Tool} = {}
local toolLowerNamesDict: {[string]: Tool} = {}
return function()
	if #toolsArray > 0 then
		return toolsArray, toolLowerNamesDict
	end
	local servicesToCheck = {
		"ReplicatedStorage",
		"ServerStorage",
		"Lighting",
		"StarterPack",
	}
	local count = 0
	for _, serviceName in servicesToCheck do
		local service = game:GetService(serviceName)
		for _, item in service:GetDescendants() do
			count += 1
			if count % 1000 == 0 then
				task.wait()
			end
			if item:IsA("Tool") then
				table.insert(toolsArray, item)
				toolLowerNamesDict[item.Name:lower()] = item
			end
		end
	end
	return toolsArray, toolLowerNamesDict
end