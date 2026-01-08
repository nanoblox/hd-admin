--!strict
local ORDER = 460
local ROLES = {script.Parent.Name, "Ability"}
local modules = script:FindFirstAncestor("HD Admin").Core.MainModule.Value.Modules
local Internal = require(modules.Internal)
local Task = require(modules.Objects.Task)
local loadCommand = Internal.loadCommand
local getHumanoid = require(modules.PlayerUtil.getHumanoid)
type Command = Task.Command

return {

    --------------------
	loadCommand("Insert", function(command: Command)
		command.order = ORDER
		command.roles = ROLES
		command.config = {
			Denylist = {0000, 0000}, -- AssetIds to block
			Replacelist = {[0000] = 0000}, -- [IdA] = IdB, where IdA is replaced with IdB
			Allowlist = {}, -- If more than 0 items, only these AssetIds can be inserted
		}
	end),

    --------------------
	
}