--!strict
local ORDER = 240
local ROLES = {script.Parent.Name, "Fun"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Gear", function(command)
	
	command.order = ORDER
	command.roles = ROLES

	------------------------------
	if command.name == "Gear" then
		command.config = {
			DenyList = {0000, 0000}, -- GearIds to block
			AllowList = {--[[0000, 0000--]]}, -- If more than 0 items, only these GearIds will be allowed
			ReplaceList = {[0000] = 0000}, -- [GearIdA] = GearIdB, where GearIdA is replaced with GearIdB
		}
	end

	------------------------------

end)