local HttpService = game:GetService("HttpService")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local Fusion = require(Packages.Fusion)
local States = require(script.Parent.Parent.States)

export type PanelEntry = {
	Id: string,
	Position: Vector2,
	Page: string,
	PagesData: {
		Execute: {
			CommandId: Fusion.Value<string?>,
		},
		Commands: {
			QuickRun: Fusion.Value<boolean>,
			ActiveTag: Fusion.Value<string?>,
		},
		User: {
			UserId: Fusion.Value<number>,
		},
		Users: {
			Selected: Fusion.Value<{ number }>,
			SelectedCallback: (() -> ())?,
		},
		About: {
			SelectedCredit: Fusion.Value<unknown>,
		},
	},
}

local NewPanel = function(Scope: Fusion.Scope<typeof(Fusion)>): PanelEntry
	local PanelEntry = {
		Id = HttpService:GenerateGUID(false),
		Open = Scope:Value(true),
		Position = Scope:Value(Vector2.new(0.005, 0.005)),
		Page = "Dashboard",
		PagesData = {
			Execute = {
				CommandId = Scope:Value(nil),
			},
			Commands = {
				QuickRun = Scope:Value(false),
				ActiveTag = Scope:Value(nil),
			},
			User = {
				UserId = Scope:Value(1),
			},
			Users = {
				Selected = Scope:Value({}),
				SelectedCallback = Scope:Value(nil),
			},
			About = {
				SelectedCredit = Scope:Value(nil),
			},
		},
	}

	local PanelsValue = Fusion.peek(States.Panels)
	table.insert(PanelsValue, PanelEntry)
	States.Panels:set(PanelsValue)

	return PanelEntry
end

local Scope = Fusion.scoped(Fusion)

local PanelsStateMod = {
	Scope = Scope,
	Panel = Fusion.Contextual(NewPanel(Scope)),
}

function PanelsStateMod.SetOpen(PanelEntry: PanelEntry, Open: boolean)
	local PanelsValue = Fusion.peek(States.Panels)

	for OtherKey, OtherPanel in PanelsValue do
		if OtherPanel.Id == PanelEntry.Id then
			OtherPanel.Open = Open
		end
	end

	States.Panels:set(PanelsValue)
end

function PanelsStateMod.New(Scope: Fusion.Scope)
	local Scope = Fusion.innerScope(Scope, Fusion)

	return NewPanel(Scope)
end

return PanelsStateMod
