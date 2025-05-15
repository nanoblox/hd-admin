--!strict

-- Cancel run if another application has initialized
local value = script:FindFirstAncestor("MainModule").Value
local modules = value.Modules
if require(modules.Framework).startAsync() == false then
    return
end

-- Destroy all instances with the attribute 'HDAdminServerOnly'
-- This is simply for easier browning in Studio because these modules/folders are already
-- hollow (placeholders) and don't actually contain any data
local function destroyServerOnlyInstances(instance: Instance)
	for _, child in instance:GetChildren() do
		if child:GetAttribute("ServerOnly") and child:GetAttribute("HasSharedDescendant") ~= true then
			child:Destroy()
		else
			destroyServerOnlyInstances(child)
		end
	end
end
destroyServerOnlyInstances(value)