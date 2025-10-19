local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local States = require(UI.States)
local Callbacks = require(UI.Callbacks)
local Types = require(UI.Utils.Types)
local Future = require(Packages.Future)
local Sift = require(Packages.Sift)

local Scope = Fusion.scoped(Fusion)

local CommandsStateMod = {}

function CommandsStateMod:GetSafe(Name: string): Fusion.Computed<Types.Command>
	return Scope:Computed(function(Use)
		local CommandValue = Use(CommandsStateMod:Get(Name))

		return Sift.Dictionary.merge(CommandValue or {}, {
			Name = "Command",
			Aliases = {},
			Arguments = {},
			Role = "Guest",
		})
	end)
end

function CommandsStateMod:Get(Name: string): Fusion.Computed<Types.Command?>
	local CommandsValue = Fusion.peek(States.Commands)
	local ExistingDetails = CommandsValue[Name]

	if ExistingDetails == nil then
		Future.Try(function()
			CommandsStateMod:Load(Name)
		end)
	end

	return Scope:Computed(function(Use)
		return Use(States.Commands)[Name]
	end)
end

function CommandsStateMod:Load(Command: string): boolean
	local Success, Command = Callbacks.RequestCommandInfo(Command)

	if Success then
		local CommandsValue = Fusion.peek(States.Commands)

		CommandsValue[Command] = Command

		States.Commands:set(CommandsValue)

		return true
	end

	return false
end

return CommandsStateMod
