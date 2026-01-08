--!strict
local ORDER = 290
local ROLES = {script.Parent.Name, "Moderate"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
return Internal.loadCommandGroup("Moderate", function(command)
	
	command.order = ORDER
	command.roles = ROLES

	------------------------------
	if command.name == "Warn" then
		command.config = {
			WarnExpiryTime = 604800, -- 1 week
			WarnActions = {
				{Warns = 3, Action = "Kick"}, -- 2 hours
				{Warns = 4, Action = "ServerBan", Duration = 7200}, -- 2 hours
				{Warns = 5, Action = "PermBan", Duration = 172800}, -- 2 days
			}
		}
	end

	------------------------------

end)