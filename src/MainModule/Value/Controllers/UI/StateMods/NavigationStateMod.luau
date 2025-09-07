local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local Sift = require(HDAdminUI.Parent.Sift)
local States = require(script.Parent.Parent.States)

local Scope = Fusion.scoped(Fusion)

local NavigationStateMod = {
	History = Scope:Value({}),
	UndoHistory = Scope:Value({}),
}

function NavigationStateMod:To(Page: string, IsUndo: boolean?)
	States.Menu.Page:set(Page)

	if not IsUndo then
		NavigationStateMod:_Record(Page)
		NavigationStateMod.UndoHistory:set({})
	end
end

function NavigationStateMod:_Record(Page: string)
	local HistoryValue = Fusion.peek(NavigationStateMod.History)

	NavigationStateMod.History:set(Sift.Array.append(HistoryValue, Page))
end

function NavigationStateMod:Undo()
	local PageHistoryValue = Fusion.peek(NavigationStateMod.History)

	if #PageHistoryValue >= 2 then
		NavigationStateMod:To(PageHistoryValue[#PageHistoryValue - 1], true)

		NavigationStateMod.History:set(Sift.Array.pop(PageHistoryValue, 1))
	end
end

function NavigationStateMod:Redo()
	local UndoHistoryValue = Fusion.peek(NavigationStateMod.UndoHistory)

	if #UndoHistoryValue >= 2 then
		NavigationStateMod:To(UndoHistoryValue[#UndoHistoryValue - 1], true)

		NavigationStateMod.UndoHistory:set(Sift.Array.pop(UndoHistoryValue, 1))
	end
end

NavigationStateMod:_Record(Fusion.peek(States.Menu.Page))

return NavigationStateMod
