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

function CommandsStateMod.GetSafe(
	Scope: Fusion.Scope<typeof(Fusion)>,
	Command: typeof(CommandsStateMod.Get(Fusion.scoped(Fusion), "Command"))
): Fusion.Computed<Types.Command>
	return Scope:Computed(function(Use)
		local CommandValue = Use(Command)

		return Sift.Dictionary.merge({
			Name = "Command",
			Aliases = {},
			Arguments = {},
			Role = "Guest",
		}, CommandValue or {})
	end)
end

function CommandsStateMod.Get(
	Scope: Fusion.Scope<typeof(Fusion)>,
	Name: Fusion.UsedAs<string>
): Fusion.Computed<Types.Command?>
	local function GetDetails(Name: string)
		local CommandsValue = Fusion.peek(States.Commands)
		local ExistingDetails = CommandsValue[Name]

		if ExistingDetails == nil then
			Future.Try(function()
				CommandsStateMod.Load(Name)
			end)
		end
	end

	GetDetails(Fusion.peek(Name))
	Scope:Observer(Name):onChange(function()
		GetDetails(Fusion.peek(Name))
	end)

	return Scope:Computed(function(Use)
		return Use(States.Commands)[Use(Name)]
	end)
end

function CommandsStateMod.Load(Command: string): boolean
	local Success, CommandInfo = Callbacks.RequestCommandInfo(Command)

	if Success then
		local CommandsValue = Fusion.peek(States.Commands)

		CommandsValue[Command] = CommandInfo

		States.Commands:set(CommandsValue)

		return true
	end

	return false
end

return CommandsStateMod
