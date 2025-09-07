local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Fusion)
local OnyxUI = require(HDAdminUI.Parent.OnyxUI)
local States = require(HDAdminUI.States)

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
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
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
			Scope:ForValues(GUIS, function(Use, Scope, Gui)
				return OnyxUI.Themer.Theme:is(Use(States.Theme)):during(function()
					return Gui.Component(Scope, Gui.Props)
				end)
			end),
		},
	}))
end
