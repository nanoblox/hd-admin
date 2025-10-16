local Main = script:FindFirstAncestor("MainModule")
local Packages = Main.Value.Packages
local UI = Main.Value.Controllers.UI
local Fusion = require(Packages.Fusion)
local OnyxUI = require(Packages.OnyxUI)
local States = require(UI.States)
local PanelsStateMod = require(UI.StateMods.PanelsStateMod)

local Children = Fusion.Children

local Menu = require(script.Parent.MenuGui)
local Prompts = require(script.Parent.PromptsGui)

export type Props = OnyxUI.FrameProps & {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util, {
		Menu = Menu,
		Prompts = Prompts,
	})

	local GUIS = {
		Prompts = {
			Component = Prompts,
			Props = {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1),
			},
		},
		Menu = {
			Component = Menu,
			Props = {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5) + UDim2.fromOffset(-20, 0),
			},
		},
	}

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Parent = Props.Parent,
		Active = false,
		Selectable = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Children] = {
			Scope:Prompts {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1),
			},
			Scope:ForValues(States.Panels, function(Use, Scope, Panel: PanelsStateMod.PanelEntry)
				return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
					return PanelsStateMod.Panel:is(Panel):during(function()
						return Scope:Menu {
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.fromScale(1, 0.5) + UDim2.fromOffset(-20, 0),
						}
					end)
				end)
			end),
		},
	}))
end
