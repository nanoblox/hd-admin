local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)

local Children = Fusion.Children

local Viewport = require(script.Parent.ViewportGui)
local GuideGui = require(script.Parent.GuideGui)

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Viewport = Viewport,
		GuideGui = GuideGui,
	})

	return Scope:New "ScreenGui" {
		Name = "HDAdmin",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.None,

		[Children] = {
			Scope:Viewport {},
			Scope:GuideGui {},
		},
	}
end
