--!strict
-- LOCAL
local Roles = {}


-- FUNCTIONS
function Roles.getRole(key: string)
	return Roles.getRoles()[key] -- Not complete, just for rapid testing
end

function Roles.getRoles(): any
	return {
		settings = {
			name = "Admin",
			key = "Admin",
			description = "This is a test role.",
			color = Color3.fromRGB(255, 0, 0),
			isDefault = false,
			isHidden = false,
			isVisible = true,
			isGamePass = false,
		},
	}
end


-- TYPES
export type RoleDetail = {any} -- Incomplete


return Roles