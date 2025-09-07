local HDAdminUI = script.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)

local OnEvent = Fusion.OnEvent

export type Props = {
	DragPosition: Fusion.UsedAs<Vector2>?,
	OnDrag: Fusion.UsedAs<(Vector2) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {})

	local DragPosition = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.DragPosition, Vector2.new()))
	local OnDrag = OnyxUI.Util.Fallback(Props.OnDrag, function() end)
	local LastDragPosition = Vector2.new()

	local function UpdateDrag(NewPosition: Vector2, Reset: boolean?)
		local OnDragValue = Fusion.peek(OnDrag)
		local OldPosition = LastDragPosition

		LastDragPosition = NewPosition

		if Reset then
			OnDragValue(NewPosition, NewPosition)
		else
			OnDragValue(OldPosition, NewPosition)
		end
	end

	return Scope:New "UIDragDetector" {
		DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale,

		[Fusion.Out "DragUDim2"] = DragPosition,

		[OnEvent "DragContinue"] = function(Position: Vector2)
			UpdateDrag(Position)
		end,
		[OnEvent "DragStart"] = function(Position: Vector2)
			UpdateDrag(Position, true)
		end,
		[OnEvent "DragEnd"] = function(Position: Vector2)
			UpdateDrag(Position)
		end,
	}
end
