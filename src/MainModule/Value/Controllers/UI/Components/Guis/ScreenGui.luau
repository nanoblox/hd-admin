local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)

local Children = Fusion.Children

local Viewport = require(script.Parent.ViewportGui)

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Viewport = Viewport,
	})

	return Scope:New "ScreenGui" {
		Name = "HDAdmin",
		Parent = Props.Parent,

		[Children] = {
			Scope:Viewport {},
		},
	}
end
