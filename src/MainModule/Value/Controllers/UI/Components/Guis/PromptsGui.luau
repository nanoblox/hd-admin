local HDAdminUI = script.Parent.Parent.Parent
local Fusion = require(HDAdminUI.Parent.Parent.Packages.Fusion)
local OnyxUI = require(HDAdminUI.Parent.Parent.Packages.OnyxUI)
local States = require(HDAdminUI.States)

local Children = Fusion.Children

local Prompt = require(script.Parent.Parent.Prompt)

export type Props = OnyxUI.AutoScalerProps & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, {
		Prompt = Prompt,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:AutoScaler(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BaseResolution = Vector2.new(700, 500),
		MaxScale = 1,
		Padding = {
			All = Scope:UDim(0, Theme.Padding["0.75"]),
		},

		[Children] = {
			Scope:Frame {
				Name = "Prompts",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromOffset(16 * 18, 0),
				List = {
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = Scope:UDim(0, Theme.Spacing["0.5"]),
				},

				[Children] = {
					Scope:ForValues(States.Prompts.Prompts, function(Use, Scope, PromptItem)
						return OnyxUI.Themer.Theme:is(Theme):during(function()
							return Scope:Prompt {
								Title = PromptItem.Title,
								Body = PromptItem.Body,
								Actions = PromptItem.Actions,
								Callback = PromptItem.Callback,
								Lifetime = PromptItem.Lifetime,
							}
						end)
					end),
				},
			},
		},
	}))
end
