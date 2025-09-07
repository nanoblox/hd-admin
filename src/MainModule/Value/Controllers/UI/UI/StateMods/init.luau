local HDAdminUI = script.Parent
local Bootloader = require(HDAdminUI.Parent.Parent.Packages.Bootloader)

local function GetModules()
	local Modules = {}

	for _, Child in ipairs(script:GetChildren()) do
		if Child:IsA("ModuleScript") then
			table.insert(Modules, Child)
		end
	end

	return Modules
end

return Bootloader(GetModules())
