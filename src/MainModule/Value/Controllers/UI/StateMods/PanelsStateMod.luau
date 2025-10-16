local HttpService = game:GetService("HttpService")

local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local Fusion = require(Packages.Fusion)
local States = require(script.Parent.Parent.States)
local Sift = require(Packages.Sift)

export type Panel = {
	Id: string,
	Open: Fusion.Value<boolean>,
	Position: Fusion.Value<Vector2>,
	Page: Fusion.Value<string>,
	PageHistory: Fusion.Value<{ string }>,
	PageUndoHistory: Fusion.Value<{ string }>,
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

local NewPanel = function(Scope: Fusion.Scope<typeof(Fusion)>): Panel
	local Panel = {
		Id = HttpService:GenerateGUID(false),
		Open = Scope:Value(true),
		Position = Scope:Value(Vector2.new(0.005, 0.005)),
		Page = Scope:Value("Dashboard"),
		PageHistory = Scope:Value({}),
		PageUndoHistory = Scope:Value({}),
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

	return Panel
end

local Scope = Fusion.scoped(Fusion)

local PanelsStateMod = {
	Scope = Scope,
	Panel = Fusion.Contextual(NewPanel(Scope)),
}

function PanelsStateMod.Undo(Panel: Panel)
	local PageHistoryValue = Fusion.peek(Panel.PageHistory)

	if #PageHistoryValue >= 2 then
		PanelsStateMod.ToPage(Panel, PageHistoryValue[#PageHistoryValue - 1], true)

		Panel.PageHistory:set(Sift.Array.pop(PageHistoryValue, 1))
	end
end

function PanelsStateMod.Redo(Panel: Panel)
	PanelsStateMod.Update(Panel, function(Panel)
		local UndoHistoryValue = Fusion.peek(Panel.PageUndoHistory)

		if #UndoHistoryValue >= 2 then
			PanelsStateMod.ToPage(Panel, UndoHistoryValue[#UndoHistoryValue - 1], true)

			Panel.PageUndoHistory:set(Sift.Array.pop(UndoHistoryValue, 1))
		end
	end)
end

function PanelsStateMod.ToPage(Panel: Panel, Page: string, Undo: boolean)
	Panel.Page:set(Page)

	if not Undo then
		PanelsStateMod.RecordPage(Panel, Page)
		Panel.PageUndoHistory:set({})
	end
end

function PanelsStateMod.RecordPage(Panel: Panel, Page: string)
	local HistoryValue = Fusion.peek(Panel.PageHistory)

	Panel.PageHistory:set(Sift.Array.append(HistoryValue, Page))
end

function PanelsStateMod.SetOpen(Panel: Panel, Open: boolean)
	PanelsStateMod.Update(Panel.Id, function(Panel)
		Panel.Open:set(Open)
	end)
end

function PanelsStateMod.Update(PanelId: string, Update: (Panel) -> Panel)
	local PanelsValue = Fusion.peek(States.Panels)

	for _, OtherPanel in PanelsValue do
		if OtherPanel.Id == PanelId then
			Update(OtherPanel)
		end
	end

	States.Panels:set(PanelsValue)
end

function PanelsStateMod.New(Scope: Fusion.Scope)
	local Scope = Fusion.innerScope(Scope, Fusion)

	local Panel = NewPanel(Scope)

	local PanelsValue = Fusion.peek(States.Panels)
	table.insert(PanelsValue, Panel)
	States.Panels:set(PanelsValue)

	PanelsStateMod.RecordPage(Panel, Fusion.peek(Panel.Page))

	return Panel
end

return PanelsStateMod
