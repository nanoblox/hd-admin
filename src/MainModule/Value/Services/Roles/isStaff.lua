local modules = script:FindFirstAncestor("MainModule").Value.Modules
local services = modules.Parent.Services
local User = require(modules.Objects.User)
local Roles = require(services.Roles)
return function(user: User.Class): boolean
	local roles = user and user.temp:get("Roles")
	if not roles then
		return false
	end
	for roleKey, _ in roles do
		local role = Roles.getRole(roleKey)
		if role.isStaff == true then
			return true
		end
	end
	return false
end